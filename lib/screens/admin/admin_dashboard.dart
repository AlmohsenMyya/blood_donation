import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.manageHospitalAdmins, icon: const Icon(Icons.admin_panel_settings)),
            Tab(text: l10n.manageHospitals, icon: const Icon(Icons.local_hospital)),
            Tab(text: l10n.manageCities, icon: const Icon(Icons.location_city)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const HospitalAdminManager(),
          const HospitalManager(),
          const CityManager(),
        ],
      ),
    );
  }
}

// --- Hospital Admin Manager ---
class HospitalAdminManager extends StatefulWidget {
  const HospitalAdminManager({super.key});

  @override
  State<HospitalAdminManager> createState() => _HospitalAdminManagerState();
}

class _HospitalAdminManagerState extends State<HospitalAdminManager> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  String? _selectedHospitalId;
  bool _loading = false;

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate() || _selectedHospitalId == null) return;
    
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final ok = await _auth.registerUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        bloodGroup: '',
        city: '',
        role: 'hospitalAdmin',
        phone: '',
        hospitalId: _selectedHospitalId,
      );

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.adminCreated)));
        _email.clear();
        _password.clear();
        _name.clear();
        setState(() => _selectedHospitalId = null);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: AppDesignConstants.edgeInsetsMedium,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(l10n.createAdmin, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.fullName, prefixIcon: const Icon(Icons.person)),
              validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: l10n.email, prefixIcon: const Icon(Icons.email)),
              validator: (v) => (v == null || v.isEmpty) ? l10n.requiredField : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password, prefixIcon: const Icon(Icons.lock)),
              validator: (v) => (v == null || v.length < 6) ? l10n.passwordMinLength : null,
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('hospitals').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final hospitals = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  value: _selectedHospitalId,
                  decoration: InputDecoration(labelText: l10n.hospitalName, prefixIcon: const Icon(Icons.local_hospital)),
                  items: hospitals.map((h) => DropdownMenuItem(
                    value: h.id,
                    child: Text(h['name']),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedHospitalId = v),
                  validator: (v) => v == null ? l10n.requiredField : null,
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _createAdmin,
                child: _loading ? const CircularProgressIndicator() : Text(l10n.createAdmin),
              ),
            ),
            const Divider(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- Hospital Manager ---
class HospitalManager extends StatefulWidget {
  const HospitalManager({super.key});

  @override
  State<HospitalManager> createState() => _HospitalManagerState();
}

class _HospitalManagerState extends State<HospitalManager> {
  final _hospitalName = TextEditingController();
  String? _selectedCity;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  Future<void> _addHospital() async {
    final name = _hospitalName.text.trim();
    if (name.isEmpty || _selectedCity == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    await _fs.collection('hospitals').add({
      'name': name,
      'city': _selectedCity,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _hospitalName.clear();
    setState(() => _selectedCity = null);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.hospitalAdded)));
  }

  Future<void> _deleteHospital(String id) async {
    final l10n = AppLocalizations.of(context)!;
    await _fs.collection('hospitals').doc(id).delete();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.hospitalDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: AppDesignConstants.edgeInsetsMedium,
          child: Column(
            children: [
              TextField(
                controller: _hospitalName,
                decoration: InputDecoration(hintText: l10n.hospitalName),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _fs.collection('cities').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final cities = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedCity,
                    hint: Text(l10n.selectCity),
                    items: cities.map((c) => DropdownMenuItem(
                      value: c['name'] as String,
                      child: Text(c['name']),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCity = v),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addHospital,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addHospital),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _fs.collection('hospitals').orderBy('name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return Center(child: Text(l10n.noHospitalsFound));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final hospital = docs[i];
                  return ListTile(
                    title: Text(hospital['name']),
                    subtitle: Text(hospital['city']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _deleteHospital(hospital.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- City Manager ---
class CityManager extends StatefulWidget {
  const CityManager({super.key});

  @override
  State<CityManager> createState() => _CityManagerState();
}

class _CityManagerState extends State<CityManager> {
  final _cityName = TextEditingController();
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  Future<void> _addCity() async {
    final name = _cityName.text.trim();
    if (name.isEmpty) return;
    
    final l10n = AppLocalizations.of(context)!;
    await _fs.collection('cities').add({'name': name});
    _cityName.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cityAdded)));
  }

  Future<void> _deleteCity(String id) async {
    final l10n = AppLocalizations.of(context)!;
    await _fs.collection('cities').doc(id).delete();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cityDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: AppDesignConstants.edgeInsetsMedium,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityName,
                  decoration: InputDecoration(hintText: l10n.cityName),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _addCity, child: const Icon(Icons.add)),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _fs.collection('cities').orderBy('name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return Center(child: Text(l10n.noCitiesFound));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final city = docs[i];
                  return ListTile(
                    title: Text(city['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => _deleteCity(city.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
