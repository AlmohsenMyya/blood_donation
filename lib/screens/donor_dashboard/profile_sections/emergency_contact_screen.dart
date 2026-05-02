import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class EmergencyContactScreen extends StatefulWidget {
  final Map<String, dynamic> existingData;
  const EmergencyContactScreen({super.key, required this.existingData});

  @override
  State<EmergencyContactScreen> createState() =>
      _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    _nameCtrl.text = d['emergencyContactName'] ?? '';
    _phoneCtrl.text = d['emergencyContactPhone'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emergencyContactName': _nameCtrl.text.trim(),
        'emergencyContactPhone': _phoneCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emergencyContactTitle)),
      body: SingleChildScrollView(
        padding: AppDesignConstants.edgeInsetsMedium,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, l10n),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.emergencyContactName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.emergencyContactPhone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.contact_phone_outlined,
                    color: AppColors.primaryRed, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.emergencyContactTitle,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(l10n.emergencyContactSubtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.emergencyContactHint,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.orange.shade300),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
