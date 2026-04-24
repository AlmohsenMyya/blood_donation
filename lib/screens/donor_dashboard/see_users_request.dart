import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class UsersRequestsScreen extends StatefulWidget {
  const UsersRequestsScreen({super.key});

  @override
  State<UsersRequestsScreen> createState() => _UsersRequestsScreenState();
}

class _UsersRequestsScreenState extends State<UsersRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchAllRequests();
  }

  Future<void> _fetchAllRequests() async {
    try {
      final snapshot = await _firestore
          .collection('blood_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      _allRequests = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data()
      }).toList();
    } catch (e) {
      debugPrint("Error fetching all requests: $e");
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
        title: Text(l10n.usersBloodRequests),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _allRequests.isEmpty
              ? Center(
                  child: Text(
                    l10n.noBloodRequestsFound,
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: AppDesignConstants.edgeInsetsMedium,
                  itemCount: _allRequests.length,
                  itemBuilder: (context, index) {
                    final request = _allRequests[index];
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
                                Text(
                                  request['patientName'] ?? l10n.unknownPatient,
                                  style: theme.textTheme.titleMedium,
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
                            _buildInfoRow(Icons.local_hospital, l10n.hospitalName, request['hospitalName']),
                            _buildInfoRow(Icons.location_on, l10n.city, request['city']),
                            _buildInfoRow(Icons.invert_colors, l10n.units, request['units'].toString()),
                            _buildInfoRow(Icons.access_time, l10n.neededAtLabel(""), 
                              request['neededAt'] != null 
                              ? DateFormat('yyyy-MM-dd HH:mm').format((request['neededAt'] as Timestamp).toDate()) 
                              : l10n.notSpecified),
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
