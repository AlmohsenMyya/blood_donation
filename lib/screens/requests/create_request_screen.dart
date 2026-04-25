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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientName = TextEditingController();
  final TextEditingController _units = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  String _selectedGroup = 'A+';
  String? _selectedCity;
  String? _selectedHospitalId;
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
    if (!_formKey.currentState!.validate() || _selectedCity == null || _selectedHospitalId == null) {
      return;
    }
    
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);

    try {
      // Fetch hospital name for convenience
      final hospDoc = await FirebaseFirestore.instance.collection('hospitals').doc(_selectedHospitalId).get();
      final hospitalName = hospDoc.data()?['name'] ?? 'Unknown Hospital';

      await FirebaseFirestore.instance.collection('blood_requests').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'patientName': _patientName.text.trim(),
        'hospitalId': _selectedHospitalId,
        'hospital': hospitalName,
        'city': _selectedCity,
        'bloodGroup': _selectedGroup,
        'units': _units.text.trim(),
        'phone': _phone.text.trim(),
        'neededAt': _neededAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(_neededAt!) : l10n.notSpecified,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', 
        'isVerified': false, 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestSubmittedSuccessfully)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestSubmittingError(e.toString()))));
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createBloodRequest,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 14),

                // Patient name
                TextFormField(
                  controller: _patientName,
                  decoration: InputDecoration(labelText: l10n.patientName),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),

                // City Dropdown
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('cities').orderBy('name').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final cities = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(labelText: l10n.city),
                      hint: Text(l10n.selectCity),
                      items: cities.map((c) => DropdownMenuItem(
                        value: c['name'] as String,
                        child: Text(c['name']),
                      )).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCity = v;
                          _selectedHospitalId = null; // Reset hospital when city changes
                        });
                      },
                      validator: (v) => v == null ? l10n.requiredField : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Hospital Dropdown (Filtered by City)
                if (_selectedCity != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('hospitals')
                      .where('city', isEqualTo: _selectedCity)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final hospitals = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedHospitalId,
                      decoration: InputDecoration(labelText: l10n.hospitalName),
                      hint: Text(l10n.hospitalName),
                      items: hospitals.map((h) => DropdownMenuItem(
                        value: h.id,
                        child: Text(h['name']),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedHospitalId = v),
                      validator: (v) => v == null ? l10n.requiredField : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // phone
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.phoneNumber),
                  validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
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
                        decoration: InputDecoration(labelText: l10n.bloodGroup),
                        items: _bloodGroups
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGroup = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _units,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.units),
                        validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
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
      ),
    );
  }
}