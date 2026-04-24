import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/screens/donors/donor_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NearbyDonorsScreen extends StatefulWidget {
  const NearbyDonorsScreen({super.key});

  @override
  State<NearbyDonorsScreen> createState() => _NearbyDonorsScreenState();
}

class _NearbyDonorsScreenState extends State<NearbyDonorsScreen> {
  String? city;
  bool isLoading = true;
  List<Map<String, dynamic>> donors = [];

  @override
  void initState() {
    super.initState();
    fetchNearbyDonors();
  }

  Future<void> _makePhoneCall(String phone) async {
    final l10n = AppLocalizations.of(context)!;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noPhoneNumber)));
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cannotMakeCall)));
    }
  }

  
  Future<void> fetchNearbyDonors() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 1️⃣ Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        city = userDoc.data()?['city'];

        if (city != null && city!.isNotEmpty) {
          // 2️⃣ Fetch ALL donors (since Firestore queries are case-sensitive)
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'donor')
              .get();

          // 3️⃣ Filter manually in Dart (case-insensitive)
          donors = querySnapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              })
              .where((donor) {
                final donorCity = (donor['city'] ?? '')
                    .toString()
                    .toLowerCase()
                    .trim();
                final userCity = city!.toLowerCase().trim();
                return donorCity == userCity;
              })
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching donors: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyDonors),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donors.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  city == null
                      ? l10n.unableToDetectCity
                      : l10n.noDonorsFoundInCity(city!),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: AppDesignConstants.edgeInsetsSmall,
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DonorDetailScreen(donorId: donor['id']),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryRed,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      donor['name'] ?? l10n.unknown,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bloodGroupLabel(donor['bloodGroup'] ?? l10n.notAvailable),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          l10n.cityLabel(donor['city'] ?? ''),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primaryRed),
                      onPressed: () {
                        final phone = donor['phone'];
                        if (phone != null && phone.toString().isNotEmpty) {
                          _makePhoneCall(phone.toString());
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
