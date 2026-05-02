import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class ManageRewardScreen extends StatefulWidget {
  final Map<String, dynamic>? existingReward;
  const ManageRewardScreen({super.key, this.existingReward});

  @override
  State<ManageRewardScreen> createState() => _ManageRewardScreenState();
}

class _ManageRewardScreenState extends State<ManageRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _selectedCity;
  bool _isActive = true;
  bool _loading = false;

  bool get _isEdit => widget.existingReward != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReward;
    if (r != null) {
      _titleCtrl.text = r['title'] as String? ?? '';
      _descCtrl.text = r['description'] as String? ?? '';
      _pointsCtrl.text = r['pointsRequired']?.toString() ?? '';
      _phoneCtrl.text = r['sponsorPhone'] as String? ?? '';
      _addressCtrl.text = r['sponsorAddress'] as String? ?? '';
      _selectedCity = r['city'] as String?;
      _isActive = r['isActive'] as bool? ?? true;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.requiredField)));
      return;
    }
    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final sponsorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final sponsorName = sponsorDoc.data()?['name'] as String? ?? '';

      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'pointsRequired': int.tryParse(_pointsCtrl.text.trim()) ?? 0,
        'sponsorPhone': _phoneCtrl.text.trim(),
        'sponsorAddress': _addressCtrl.text.trim(),
        'sponsorId': uid,
        'sponsorName': sponsorName,
        'city': _selectedCity,
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final col = FirebaseFirestore.instance.collection('rewards');
      if (_isEdit) {
        await col.doc(widget.existingReward!['id'] as String).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await col.add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.rewardSaved)));
        Navigator.pop(context, true);
      }
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
      appBar: AppBar(
        title: Text(_isEdit ? l10n.editReward : l10n.addReward),
      ),
      body: SingleChildScrollView(
        padding: AppDesignConstants.edgeInsetsMedium,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader(l10n.rewardTitle, Icons.card_giftcard, theme),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.rewardTitle,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.rewardDescription,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pointsCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.pointsRequired,
                  prefixIcon: const Icon(Icons.stars_outlined),
                  suffixText: '⭐',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.requiredField;
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return l10n.requiredField;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(l10n.sponsorOrgName, Icons.store, theme),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.sponsorPhone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.sponsorAddress,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cities')
                    .orderBy('name')
                    .snapshots(),
                builder: (ctx, snap) {
                  final cities = snap.data?.docs ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      labelText: l10n.city,
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                    items: cities
                        .map((c) => DropdownMenuItem(
                            value: c['name'] as String,
                            child: Text(c['name'] as String)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCity = v),
                    validator: (v) => v == null ? l10n.requiredField : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(l10n.activeRewards),
                activeColor: AppColors.success,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
