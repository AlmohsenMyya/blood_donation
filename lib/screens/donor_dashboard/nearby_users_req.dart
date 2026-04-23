import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NearbyRequestsScreen extends StatefulWidget {
  const NearbyRequestsScreen({super.key});

  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  late final Stream<QuerySnapshot> _requestsStream;
  String? donorCity;

  @override
  void initState() {
    super.initState();
    final donor = FirebaseAuth.instance.currentUser;
    if (donor != null) {
      // Get donor city
      FirebaseFirestore.instance.collection('users').doc(donor.uid).get().then((doc) {
        if (doc.exists) {
          setState(() {
            donorCity = (doc.data()?['city'] ?? '').toString().toLowerCase().trim();
          });
        }
      });

      _requestsStream = FirebaseFirestore.instance
          .collection('blood_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _requestsStream = const Stream.empty();
    }
  }

  void _callNumber(String number) async {
    final l10n = AppLocalizations.of(context)!;
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noPhoneNumber)));
      return;
    }
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cannotMakeCall)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(l10n.nearbyRequests),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: SafeArea(
        child: donorCity == null
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : StreamBuilder<QuerySnapshot>(
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

                  final requests = snapshot.data!.docs
                      .where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final requestCity = (data['city'] ?? '').toString().toLowerCase().trim();
                        return requestCity == donorCity;
                      })
                      .toList();

                  if (requests.isEmpty) {
                    return Center(
                      child: Text(l10n.noNearbyRequests, style: const TextStyle(color: Colors.white70)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final doc = requests[index];
                      final data = doc.data() as Map<String, dynamic>;
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
                                    data['status'] == 'done' ? Icons.check_circle : Icons.pending_actions,
                                    color: data['status'] == 'done' ? Colors.green : Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(l10n.hospitalLabel(data['hospital'] ?? l10n.notAvailable),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(l10n.cityLabel(data['city'] ?? l10n.notAvailable),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                  Text(l10n.phoneLabel(data['phone'] ?? l10n.notAvailable),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(l10n.unitsLabel(data['units'] ?? l10n.notAvailable),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(l10n.neededAtLabel(data['neededAt'] ?? l10n.notAvailable),
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              
                              const SizedBox(height: 10),
                              Text(l10n.requestedOnLabel(formattedDate),
                                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
                              const SizedBox(height: 10),
                              if (data['status'] != 'done')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _callNumber(data['phone'] ?? ''),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.call, color: Colors.white),
                                    label: Text(l10n.call, style: const TextStyle(color: Colors.white)),
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
