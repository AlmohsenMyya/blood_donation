import 'package:sheryan/core/utils/qr_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _lastDonated = TextEditingController();

  String? _selectedCity;
  String _bloodGroup = '';
  String _accountType = '';
  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    // Populate form as soon as profile data arrives from the stream.
    // Using listenManual with fireImmediately so we don't miss already-loaded data.
    ref.listenManual(
      userProfileProvider,
      (_, next) {
        final profile = next.asData?.value;
        if (profile == null || _formInitialized || !mounted) return;
        _formInitialized = true;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _name.text = profile['name'] as String? ?? '';
          _phone.text = profile['phone'] as String? ?? '';
          _selectedCity = profile['city'] as String?;
          _lastDonated.text = profile['lastDonated'] as String? ?? '';
          _bloodGroup = profile['bloodGroup'] as String? ?? l10n.notAvailable;
          final role = profile['role'] as String? ?? 'user';
          _accountType = role == 'donor' ? l10n.roleDonor : l10n.roleUser;
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _lastDonated.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    await _firestore.collection('users').doc(user.uid).update({
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'city': _selectedCity,
      'lastDonated': _lastDonated.text.trim(),
    });

    // Invalidate provider so HomeScreen and other screens reflect the update.
    ref.invalidate(userProfileProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
    );
  }

  Stream<int> _getRequestCount() {
    return _firestore
        .collection('blood_requests')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileAsync = ref.watch(userProfileProvider);
    final isLoading = !_formInitialized && profileAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  _formInitialized = false;
                  ref.invalidate(userProfileProvider);
                },
                color: AppColors.primaryRed,
                backgroundColor: colorScheme.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppDesignConstants.edgeInsetsMedium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total Requests Card
                      StreamBuilder<int>(
                        stream: _getRequestCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.totalRequests,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    '$count',
                                    style: theme.textTheme.displayMedium
                                        ?.copyWith(
                                      color: AppColors.accentRed,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      // Profile Form
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(l10n.name, _name),
                              const SizedBox(height: 12),
                              _buildTextField(
                                l10n.email,
                                TextEditingController(text: user.email),
                                enabled: false,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(l10n.phone, _phone),
                              const SizedBox(height: 12),

                              // City Dropdown
                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('cities')
                                    .orderBy('name')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const LinearProgressIndicator();
                                  }
                                  final cities = snapshot.data!.docs;
                                  return DropdownButtonFormField<String>(
                                    value: _selectedCity,
                                    dropdownColor: colorScheme.surface,
                                    decoration: InputDecoration(
                                        labelText: l10n.city),
                                    items: cities
                                        .map((c) => DropdownMenuItem(
                                              value: c['name'] as String,
                                              child: Text(c['name']),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedCity = v),
                                    validator: (v) => v == null
                                        ? l10n.requiredField
                                        : null,
                                  );
                                },
                              ),

                              const SizedBox(height: 12),
                              _buildTextField(
                                l10n.bloodGroup,
                                TextEditingController(text: _bloodGroup),
                                enabled: false,
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                l10n.accountType,
                                TextEditingController(text: _accountType),
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: Text(l10n.saveChanges),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          QrDialog.show(
                            context,
                            data: user.uid,
                            label: _name.text,
                            idLabel: l10n.donorId,
                          );
                        },
                        icon: const Icon(Icons.qr_code),
                        label: Text(l10n.donorCard),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryRed),
                          foregroundColor: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          (enabled && (v == null || v.isEmpty)) ? l10n.requiredField : null,
    );
  }
}
