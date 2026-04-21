
import 'package:sheryan/screens/donor_dashboard/donors_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class DonorsList extends StatefulWidget {
  const DonorsList({super.key});

  @override
  State<DonorsList> createState() => _DonorsListState();
}

class _DonorsListState extends State<DonorsList> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> filteredDonors = [];
  bool loading = true;

  String selectedCity = 'All';
  String selectedBlood = 'All';

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }

  Future<void> _loadDonors() async {
    try {
      final snapshot =
          await _fs.collection('users').where('role', isEqualTo: 'donor').get();

      donors = snapshot.docs
          .map((d) => {
                'id': d.id,
                ...d.data(),
              })
          .toList();

      filteredDonors = List.from(donors);
    } catch (e) {
      debugPrint('Error loading donors: $e');
      donors = [];
      filteredDonors = [];
    }
    setState(() => loading = false);
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
    // Build explicit List<String> for cities (unique)
    final citySet = <String>{};
    for (final d in donors) {
      final c = (d['city'] ?? '').toString();
      if (c.isNotEmpty) citySet.add(c);
    }
    final List<String> cities = [l10n.all, ...citySet];

    final List<String> bloodGroups = [
      l10n.all,
      'A+',
      'A-',
      'B+',
      'B-',
      'O+',
      'O-',
      'AB+',
      'AB-'
    ];

    // Ensure selected values are valid in current language
    if (selectedCity == 'All') selectedCity = l10n.all;
    if (selectedBlood == 'All') selectedBlood = l10n.all;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.availableDonors),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0F0F0F),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              children: [
                // Filter Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCity,
                          dropdownColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: l10n.city,
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF161616),
                          ),
                          items: cities
                              .map((city) => DropdownMenuItem<String>(
                                    value: city,
                                    child: Text(city,
                                        style:
                                            const TextStyle(color: Colors.white)),
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
                          dropdownColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: l10n.bloodGroup,
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFF161616),
                          ),
                          items: bloodGroups
                              .map((bg) => DropdownMenuItem<String>(
                                    value: bg,
                                    child: Text(bg,
                                        style:
                                            const TextStyle(color: Colors.white)),
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

                // Donor List
                Expanded(
                  child: filteredDonors.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noDonorsFound,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDonors.length,
                          itemBuilder: (ctx, i) {
                            final donor = filteredDonors[i];
                            final blood = (donor['bloodGroup'] ?? l10n.notAvailable).toString();
                            final city = (donor['city'] ?? l10n.notAvailable).toString();
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DonorDetails(donorId: donor['id']),
                                  ),
                                );
                              },
                              child: Card(
                                color: const Color(0xFF161616),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red,
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
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    '$city • $blood',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.call, color: Colors.red),
                                    onPressed: () => _makePhoneCall(
                                        (donor['phone'] ?? '').toString()),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
