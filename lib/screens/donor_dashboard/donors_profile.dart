import 'package:sheryan/core/utils/qr_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ...
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _lastDonated = TextEditingController();

  String _bloodGroup = '';
  String _accountType = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔁 Load user profile from Firestore
  Future<void> _loadProfile() async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _name.text = data['name'] ?? '';
      _phone.text = data['phone'] ?? '';
      _city.text = data['city'] ?? '';
      _lastDonated.text = data['lastDonated'] ?? '';
      _bloodGroup = data['bloodGroup'] ?? l10n.notAvailable;
      _accountType = data['role'] ?? 'user';
      _loading = false;
    });
  }

  // date picker for last donated date
  Future<void> _pickLastDonatedDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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

    if (pickedDate != null) {
      setState(() {
        _lastDonated.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // 💾 Save updated profile data
  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    await _firestore.collection('users').doc(user.uid).update({
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'city': _city.text.trim(),
      'lastDonated': _lastDonated.text.trim(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.profileUpdatedSuccessfully)),
    );
  }

  

  // 🔄 Manual refresh
  Future<void> _refreshProfile() async {
    await _loadProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshProfile,
                color: AppColors.primaryRed,
                backgroundColor: AppColors.backgroundBlack,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppDesignConstants.edgeInsetsMedium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // 🧑 Profile Header Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryRed, AppColors.accentRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppDesignConstants.borderRadiusLarge,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: AppDesignConstants.edgeInsetsMedium,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.bloodtype,
                                  size: 40, color: AppColors.primaryRed),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name.text.isNotEmpty
                                        ? _name.text
                                        : l10n.bloodDonor,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _bloodGroup == 'N/A' ? l10n.notAvailable : _bloodGroup,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _city.text.isNotEmpty
                                        ? _city.text
                                        : l10n.unknownCity,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🧾 Profile Form Card
                      Card(
                        child: Padding(
                          padding: AppDesignConstants.edgeInsetsMedium,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(l10n.name, _name,
                                    icon: Icons.person),
                                const SizedBox(height: 12),
                                _buildTextField(l10n.email,
                                    TextEditingController(text: user.email),
                                    enabled: false,
                                    icon: Icons.email),
                                const SizedBox(height: 12),
                                _buildTextField(l10n.phone, _phone,
                                    icon: Icons.phone),
                                const SizedBox(height: 12),
                                _buildTextField(l10n.city, _city,
                                    icon: Icons.location_city),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  l10n.bloodGroup,
                                  TextEditingController(text: _bloodGroup == 'N/A' ? l10n.notAvailable : _bloodGroup),
                                  enabled: false,
                                  icon: Icons.bloodtype,
                                ),
                                const SizedBox(height: 12),
                                _buildDateField(
                                    l10n.lastDonated, _lastDonated,
                                    icon: Icons.calendar_today),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  l10n.accountType,
                                  TextEditingController(text: _accountType == 'donor' ? l10n.roleDonor : l10n.roleUser),
                                  enabled: false,
                                  icon: Icons.verified_user,
                                ),
                              ],
                            ),
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
                          side: const BorderSide(color: Colors.white70),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // 🧱 Reusable text field widget
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, IconData? icon}) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon)
            : const Icon(Icons.text_fields),
        labelText: label,
      ),
      validator: (v) =>
          (enabled && (v == null || v.isEmpty)) ? l10n.requiredField : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      {IconData? icon}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon:
            icon != null ? Icon(icon) : null,
        labelText: label,
      ),
      onTap: _pickLastDonatedDate,
    );
  }
}
