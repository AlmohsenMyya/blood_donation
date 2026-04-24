
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.backgroundDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_neededAt ?? now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.backgroundDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
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
        'isVerified': false, // ✅ Added for validation by hospital admin
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestBlood),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDesignConstants.edgeInsetsMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.createBloodRequest,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 14),

              // Patient name
              TextField(
                controller: _patientName,
                decoration: InputDecoration(
                  labelText: l10n.patientName,
                ),
              ),
              const SizedBox(height: 12),

              // Hospital
              TextField(
                controller: _hospital,
                decoration: InputDecoration(
                  labelText: l10n.hospitalName,
                ),
              ),
              const SizedBox(height: 12),

              // City
              TextField(
                controller: _city,
                decoration: InputDecoration(
                  labelText: l10n.city,
                ),
              ),
              const SizedBox(height: 12),

              // phone
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                ),
              ),
              const SizedBox(height: 12),

              // Blood group + units row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGroup,
                      dropdownColor: AppColors.surfaceDark,
                      decoration: InputDecoration(
                        labelText: l10n.bloodGroup,
                      ),
                      items: _bloodGroups
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
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
                      decoration: InputDecoration(
                        labelText: l10n.units,
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
                    color: AppColors.fieldDark,
                    borderRadius: AppDesignConstants.borderRadiusMedium,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _neededAt == null
                              ? l10n.whenBloodNeededTap
                              : l10n.neededAtValue(DateFormat('dd MMM yyyy, hh:mm a').format(_neededAt!)),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const Icon(Icons.access_time, color: AppColors.primaryRed),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitRequest,
                  child: _loading ? const CircularProgressIndicator(color: AppColors.textPrimary) : Text(l10n.submitRequest),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
