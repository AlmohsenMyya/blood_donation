
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/l10n/app_localizations.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      
      final role = data['role'] ?? 'user';
      _accountType = role == 'donor' ? l10n.roleDonor : l10n.roleUser;
      
      _loading = false;
    });
  }

  // 💾 Save updated profile data
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

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

  // 🔢 Stream to track total user requests in real-time
  Stream<int> _getRequestCount() {
    return _firestore
        .collection('blood_requests')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 🔄 Manual refresh
  Future<void> _refreshProfile() async {
    await _loadProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.myProfile, style: const TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshProfile,
                color: Colors.red,
                backgroundColor: Colors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🩸 Total Requests Card
                      StreamBuilder<int>(
                        stream: _getRequestCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Card(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.totalRequests,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      // 🧾 Profile Form
                      Container(
                        padding: const EdgeInsets.all(20),
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
                              _buildTextField(l10n.city, _city),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          l10n.saveChanges,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // 🧱 Reusable text field widget
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (v) =>
          (enabled && (v == null || v.isEmpty)) ? l10n.requiredField : null,
    );
  }
}