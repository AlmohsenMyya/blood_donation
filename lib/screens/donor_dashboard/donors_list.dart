import 'dart:convert';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/screens/donor_dashboard/donors_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/providers/connectivity/connectivity_provider.dart';

class DonorsList extends ConsumerStatefulWidget {
  const DonorsList({super.key});

  @override
  ConsumerState<DonorsList> createState() => _DonorsListState();
}

class _DonorsListState extends ConsumerState<DonorsList> {
  static const _kDonorsCacheKey = 'sheryan_donors_cache';

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> filteredDonors = [];
  bool loading = true;
  bool _fromCache = false;

  String selectedCity = 'All';
  String selectedBlood = 'All';

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _saveDonorsToCache(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDonorsCacheKey, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>?> _loadDonorsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDonorsCacheKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _loadDonors() async {
    setState(() => loading = true);
    final isOnline = ref.read(connectivityProvider);

    if (isOnline) {
      try {
        final snapshot = await _fs
            .collection('users')
            .where('role', isEqualTo: 'donor')
            .get();
        final fetched = snapshot.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList();
        await _saveDonorsToCache(fetched);
        donors = fetched;
        _fromCache = false;
      } catch (_) {
        final cached = await _loadDonorsFromCache();
        donors = cached ?? [];
        _fromCache = donors.isNotEmpty;
      }
    } else {
      final cached = await _loadDonorsFromCache();
      donors = cached ?? [];
      _fromCache = donors.isNotEmpty;
    }

    filteredDonors = List.from(donors);
    if (mounted) setState(() => loading = false);
  }

  void _filterDonors() {
    setState(() {
      filteredDonors = donors.where((donor) {
        final donorCity = (donor['city'] ?? '').toString();
        final donorBlood = (donor['bloodGroup'] ?? '').toString();
        final matchesCity = selectedCity == 'All' || donorCity == selectedCity;
        final matchesBlood =
            selectedBlood == 'All' || donorBlood == selectedBlood;
        return matchesCity && matchesBlood;
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phone) async {
    final l10n = AppLocalizations.of(context)!;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noPhoneNumber)));
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.cannotMakeCall)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOnline = ref.watch(connectivityProvider);

    final citySet = <String>{};
    for (final d in donors) {
      final c = (d['city'] ?? '').toString();
      if (c.isNotEmpty) citySet.add(c);
    }
    final List<String> cities = [l10n.all, ...citySet];

    final List<String> bloodGroups = [
      l10n.all,
      'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
    ];

    if (selectedCity == 'All') selectedCity = l10n.all;
    if (selectedBlood == 'All') selectedBlood = l10n.all;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.availableDonors),
        actions: [
          if (!isOnline)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.wifi_off, color: Colors.orange, size: 20),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_fromCache)
                  Container(
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.cached,
                            size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          l10n.cachedDonorsLabel(donors.length),
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: AppDesignConstants.edgeInsetsSmall,
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCity,
                          dropdownColor: colorScheme.surface,
                          decoration: InputDecoration(labelText: l10n.city),
                          items: cities
                              .map((city) => DropdownMenuItem<String>(
                                    value: city,
                                    child: Text(city),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            selectedCity = value;
                            _filterDonors();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedBlood,
                          dropdownColor: colorScheme.surface,
                          decoration:
                              InputDecoration(labelText: l10n.bloodGroup),
                          items: bloodGroups
                              .map((bg) => DropdownMenuItem<String>(
                                    value: bg,
                                    child: Text(bg),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            selectedBlood = value;
                            _filterDonors();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredDonors.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noDonorsFound,
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDonors,
                          child: ListView.builder(
                            itemCount: filteredDonors.length,
                            itemBuilder: (ctx, i) {
                              final donor = filteredDonors[i];
                              final blood = (donor['bloodGroup'] ??
                                      l10n.notAvailable)
                                  .toString();
                              final city =
                                  (donor['city'] ?? l10n.notAvailable)
                                      .toString();
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DonorDetails(
                                            donorId: donor['id']),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primaryRed,
                                    child: Text(
                                      blood,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    donor['name'] ?? l10n.unknown,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  subtitle: Text(
                                    '$city • $blood',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.call,
                                        color: AppColors.primaryRed),
                                    onPressed: () => _makePhoneCall(
                                        (donor['phone'] ?? '').toString()),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
