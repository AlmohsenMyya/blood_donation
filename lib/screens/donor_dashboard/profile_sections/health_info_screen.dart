import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/core/utils/points_ui_utils.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/services/points_service.dart';

class HealthInfoScreen extends StatefulWidget {
  final Map<String, dynamic> existingData;
  const HealthInfoScreen({super.key, required this.existingData});

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _gender;
  String? _smokingStatus;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    _heightCtrl.text = d['height']?.toString() ?? '';
    _weightCtrl.text = d['weight']?.toString() ?? '';
    _gender = d['gender'];
    _smokingStatus = d['smokingStatus'];
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null || _smokingStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requiredField)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'height': double.tryParse(_heightCtrl.text.trim()),
        'weight': double.tryParse(_weightCtrl.text.trim()),
        'gender': _gender,
        'smokingStatus': _smokingStatus,
      });

      // Award points for completed milestones
      final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final profile = snap.data() ?? {};
      final pts = await PointsService().checkAndAwardProfileMilestones(uid, profile);

      if (mounted) {
        if (pts > 0) showPointsGainedSnack(context, pts);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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
      appBar: AppBar(title: Text(l10n.healthInfoTitle)),
      body: SingleChildScrollView(
        padding: AppDesignConstants.edgeInsetsMedium,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(Icons.monitor_weight_outlined, l10n.healthInfoTitle,
                  l10n.healthInfoSubtitle, theme),
              const SizedBox(height: 20),

              TextFormField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.height,
                  prefixIcon: const Icon(Icons.height),
                  suffixText: 'cm',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.weight,
                  prefixIcon: const Icon(Icons.fitness_center),
                  suffixText: 'kg',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 20),

              Text(l10n.gender, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildChipGroup(
                options: ['male', 'female'],
                labels: [l10n.genderMale, l10n.genderFemale],
                selected: _gender,
                onSelected: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 20),

              Text(l10n.smokingStatus, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildChipGroup(
                options: ['never', 'former', 'current'],
                labels: [
                  l10n.smokingNever,
                  l10n.smokingFormer,
                  l10n.smokingCurrent,
                ],
                selected: _smokingStatus,
                onSelected: (v) => setState(() => _smokingStatus = v),
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

  Widget _buildHeader(
      IconData icon, String title, String subtitle, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
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
            child: Icon(icon, color: AppColors.primaryRed, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required List<String> labels,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final isSelected = selected == options[i];
        return ChoiceChip(
          label: Text(labels[i]),
          selected: isSelected,
          onSelected: (_) => onSelected(options[i]),
          selectedColor: AppColors.primaryRed,
          backgroundColor: colorScheme.surfaceContainerHighest,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.5),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }),
    );
  }
}
