
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          .where('userId', isEqualTo: user.uid) // ✅ Only show logged-in user's requests
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(l10n.myBloodRequests),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            }

            if (snapshot.hasError) {
              return Center(child: Text(l10n.genericError(snapshot.error.toString()), style: const TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(l10n.noBloodRequestsFound, style: const TextStyle(color: Colors.white70)),
              );
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
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
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red[600],
                              child: Text(
                                (data['bloodGroup'] ?? '?'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['patientName'] ?? l10n.unknownPatient,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Icon(
                              status == 'done' ? Icons.check_circle : Icons.pending_actions,
                              color: status == 'done' ? Colors.green : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.hospitalLabel((data['hospital'] ?? l10n.notAvailable).toString()),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(l10n.cityLabel((data['city'] ?? l10n.notAvailable).toString()),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                             Text(l10n.phoneLabel((data['phone'] ?? l10n.notAvailable).toString()),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(l10n.unitsLabel((data['units'] ?? l10n.notAvailable).toString()),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(l10n.neededAtLabel((data['neededAt'] ?? l10n.notAvailable).toString()),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 10),
                        Text(l10n.requestedOnLabel(formattedDate),
                            style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 10),
                        if (status != 'done')
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _markAsDone(doc.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: Text(l10n.markAsDone, style: const TextStyle(color: Colors.white)),
                            ),
                          ),
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
}
