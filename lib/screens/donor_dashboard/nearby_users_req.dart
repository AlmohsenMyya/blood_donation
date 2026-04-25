import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NearbyRequestsScreen extends StatefulWidget {
  const NearbyRequestsScreen({super.key});

  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _nearbyRequests = [];
  String? _userCity;

  @override
  void initState() {
    super.initState();
    _fetchNearbyRequests();
  }

  Future<void> _fetchNearbyRequests() async {
    try {
      // 1. Get current position (Simplified for demo, in production use actual user city from profile)
      _userCity = "Nablus"; // Mock

      // 2. Fetch requests from Firestore
      final snapshot = await _firestore
          .collection('blood_requests')
          .where('city', isEqualTo: _userCity)
          .where('status', isEqualTo: 'pending')
          .get();

      _nearbyRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data()
      }).toList();

    } catch (e) {
      debugPrint("Error fetching nearby requests: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _callUser(String phone) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotMakeCall)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyRequests),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _nearbyRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 60, color: AppColors.textGrey),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noNearbyRequests,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: AppDesignConstants.edgeInsetsMedium,
                  itemCount: _nearbyRequests.length,
                  itemBuilder: (context, index) {
                    final request = _nearbyRequests[index];
                    final isVerified = request['isVerified'] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: AppDesignConstants.edgeInsetsMedium,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request['patientName'] ?? l10n.unknownPatient,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      if (isVerified)
                                        Row(
                                          children: [
                                            const Icon(Icons.verified, color: Colors.blue, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              l10n.statusVerified,
                                              style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryRed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    request['bloodGroup'] ?? '?',
                                    style: const TextStyle(
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(Icons.local_hospital, l10n.hospitalName, request['hospital'] ?? request['hospitalName'] ?? ''),
                            _buildInfoRow(Icons.location_on, l10n.city, request['city']),
                            _buildInfoRow(Icons.invert_colors, l10n.units, request['units'].toString()),
                            _buildInfoRow(Icons.access_time, l10n.neededAtLabel(""), request['neededAt']?.toString() ?? l10n.notSpecified),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _callUser(request['phone'] ?? ''),
                                icon: const Icon(Icons.phone),
                                label: Text(l10n.call),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}
