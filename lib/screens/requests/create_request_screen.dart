
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RequestBloodScreen extends StatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final TextEditingController _patientName = TextEditingController();
  final TextEditingController _hospital = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _units = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  String _selectedGroup = 'A+';
  DateTime? _neededAt;
  bool _loading = false;

  Future<void> _pickNeededDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _neededAt ?? now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_neededAt ?? now),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _neededAt = dt);
  }

  Future<void> _submitRequest() async {
    final l10n = AppLocalizations.of(context)!;
    final patient = _patientName.text.trim();
    final hospital = _hospital.text.trim();
    final city = _city.text.trim();
    final units = _units.text.trim();
    final phone = _phone.text.trim();

    if (patient.isEmpty || hospital.isEmpty || city.isEmpty || units.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestFillRequiredFields)));
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.collection('blood_requests').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'patientName': patient,
        'hospital': hospital,
        'city': city,
        'bloodGroup': _selectedGroup,
        'units': units,
        'phone': phone,
        'neededAt': _neededAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(_neededAt!) : l10n.notSpecified,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending | done
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestSubmittedSuccessfully)));
      // clear form
      _patientName.clear();
      _hospital.clear();
      _city.clear();
      _units.clear();
      setState(() {
        _selectedGroup = 'A+';
        _neededAt = null;
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestSubmittingError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.requestBlood),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.createBloodRequest,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              // Patient name
              TextField(
                controller: _patientName,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.patientName,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF161616),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Hospital
              TextField(
                controller: _hospital,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.hospitalName,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF161616),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // City
              TextField(
                controller: _city,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.city,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF161616),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // phone
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF161616),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Blood group + units row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGroup,
                      dropdownColor: const Color(0xFF161616),
                      decoration: InputDecoration(
                        labelText: l10n.bloodGroup,
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: _bloodGroups
                          .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(color: Colors.white))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGroup = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _units,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: l10n.units,
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Needed at picker (shows selected value)
              GestureDetector(
                onTap: _pickNeededDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _neededAt == null
                              ? l10n.whenBloodNeededTap
                              : l10n.neededAtValue(DateFormat('dd MMM yyyy, hh:mm a').format(_neededAt!)),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      const Icon(Icons.access_time, color: Colors.red),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(l10n.submitRequest,style: const TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
