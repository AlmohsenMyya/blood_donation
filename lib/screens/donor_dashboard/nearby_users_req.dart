import 'package:sheryan/core/utils/whatsapp_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ... rest of imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/core/utils/blood_logic.dart';
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
  String? _userBloodGroup;

  @override
  void initState() {
    super.initState();
    _fetchNearbyRequests();
  }

  Future<void> _fetchNearbyRequests() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _userCity = userDoc.data()?['city'];
        _userBloodGroup = userDoc.data()?['bloodGroup'];

        if (_userCity != null && _userBloodGroup != null) {
          final compatibleRecipientTypes = BloodLogic.getCompatibleRecipients(_userBloodGroup!);

          final snapshot = await _firestore
              .collection('blood_requests')
              .where('city', isEqualTo: _userCity)
              .where('status', isEqualTo: 'pending')
              .where('bloodGroup', whereIn: compatibleRecipientTypes)
              .get();

          _nearbyRequests = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data()
          }).toList();

          // Sort: Perfect matches first
          _nearbyRequests.sort((a, b) {
            bool aMatch = a['bloodGroup'] == _userBloodGroup;
            bool bMatch = b['bloodGroup'] == _userBloodGroup;
            if (aMatch && !bMatch) return -1;
            if (!aMatch && bMatch) return 1;
            return 0;
          });
        }
      }
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
    final colorScheme = theme.colorScheme;

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
                      Icon(Icons.location_off, size: 60, color: colorScheme.onSurface.withOpacity(0.4)),
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
                    final bool isPerfect = request['bloodGroup'] == _userBloodGroup;

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
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPerfect ? AppColors.primaryRed : Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        request['bloodGroup'] ?? '?',
                                        style: TextStyle(
                                          color: isPerfect ? Colors.white : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isPerfect)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text("MATCH", style: TextStyle(color: AppColors.success, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(Icons.local_hospital, l10n.hospitalName, request['hospital'] ?? request['hospitalName'] ?? ''),
                            _buildInfoRow(Icons.location_on, l10n.city, request['city']),
                            _buildInfoRow(Icons.invert_colors, l10n.units, request['units'].toString()),
                            _buildInfoRow(Icons.access_time, l10n.neededAtLabel(""), request['neededAt']?.toString() ?? l10n.notSpecified),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _callUser(request['phone'] ?? ''),
                                    icon: const Icon(Icons.phone),
                                    label: Text(l10n.call),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      WhatsAppHelper.openWhatsApp(
                                        context: context,
                                        phone: request['phone'] ?? '',
                                        message: l10n.whatsappDonorMessage(
                                          request['patientName'] ?? l10n.unknownPatient,
                                          _userBloodGroup ?? '?',
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.chat),
                                    label: Text(l10n.whatsapp),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Text("$label: ", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
          Expanded(child: Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 13))),
        ],
      ),
    );
  }
}
