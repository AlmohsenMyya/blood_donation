
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RequestsListScreen extends StatefulWidget {
  const RequestsListScreen({super.key});

  @override
  State<RequestsListScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsListScreen> {
  late final Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _requestsStream = FirebaseFirestore.instance
          .collection('blood_requests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _requestsStream = const Stream.empty();
    }
  }

  Future<void> _markAsDone(String docId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsDone),
        content: Text(l10n.confirmRequestFulfilled),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yesDone),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('blood_requests')
          .doc(docId)
          .update({'status': 'done'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBloodRequests),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(l10n.genericError(snapshot.error.toString())));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(l10n.noBloodRequestsFound, style: theme.textTheme.bodyMedium),
              );
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              padding: AppDesignConstants.edgeInsetsMedium,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final doc = requests[index];
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                final createdAt = data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: AppDesignConstants.edgeInsetsMedium,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryRed,
                              child: Text(
                                (data['bloodGroup'] ?? '?'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['patientName'] ?? l10n.unknownPatient,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            Icon(
                              status == 'done' ? Icons.check_circle : Icons.pending_actions,
                              color: status == 'done' ? AppColors.success : AppColors.warning,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.local_hospital, l10n.hospitalName, data['hospital']),
                        _buildInfoRow(Icons.location_on, l10n.city, data['city']),
                        _buildInfoRow(Icons.phone, l10n.phoneNumber, data['phone']),
                        _buildInfoRow(Icons.invert_colors, l10n.units, data['units']),
                        _buildInfoRow(Icons.access_time, l10n.neededAtLabel("").replaceAll(":", ""), data['neededAt']),
                        
                        const SizedBox(height: 12),
                        Text(
                          l10n.requestedOnLabel(formattedDate),
                          style: theme.textTheme.labelSmall,
                        ),
                        if (status != 'done') ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _markAsDone(doc.id),
                              icon: const Icon(Icons.check),
                              label: Text(l10n.markAsDone),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Text("$label: ", style: theme.textTheme.labelSmall),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
