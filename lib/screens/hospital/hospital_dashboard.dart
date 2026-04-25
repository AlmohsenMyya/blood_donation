import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';

class HospitalDashboard extends ConsumerWidget {
  const HospitalDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final adminProfile = ref.watch(userProfileProvider).value;
    final hospitalId = adminProfile?['hospitalId'];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hospitalAdminDashboard),
      ),
      body: Column(
        children: [
          Padding(
            padding: AppDesignConstants.edgeInsetsMedium,
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.verified_user,
                    title: l10n.verifyRequest,
                    color: AppColors.hospitalPrimary,
                    onTap: () => _openScanner(context, isVerifyOnly: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.handshake,
                    title: l10n.registerDonation,
                    color: AppColors.success,
                    onTap: () => _openScanner(context, isVerifyOnly: false),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: AppColors.hospitalPrimary),
                const SizedBox(width: 8),
                Text(l10n.incomingRequests, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Expanded(
            child: hospitalId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('blood_requests')
                        .where('hospitalId', isEqualTo: hospitalId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return Center(child: Text(l10n.noRequestsFound));

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          final isDone = data['status'] == 'done';
                          final isVerified = data['isVerified'] ?? false;

                          return Card(
                            child: ListTile(
                              title: Text(data['patientName'] ?? ''),
                              subtitle: Text("${data['bloodGroup']} • ${data['units']} units"),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (isDone)
                                    const Icon(Icons.check_circle, color: AppColors.success)
                                  else if (isVerified)
                                    const Icon(Icons.verified, color: Colors.blue)
                                  else
                                    const Icon(Icons.pending, color: Colors.orange),
                                  Text(
                                    isDone ? l10n.done : (isVerified ? "Verified" : l10n.pending),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDone ? AppColors.success : (isVerified ? Colors.blue : Colors.orange),
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
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context,
      {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: AppDesignConstants.borderRadiusMedium),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  void _openScanner(BuildContext context, {required bool isVerifyOnly}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(isVerifyOnly: isVerifyOnly),
      ),
    );
  }
}

class ScannerScreen extends ConsumerStatefulWidget {
  final bool isVerifyOnly;
  const ScannerScreen({super.key, required this.isVerifyOnly});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  String? donorId;
  String? requestId;
  bool isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => isProcessing = true);

    if (widget.isVerifyOnly) {
      await _handleVerifyRequest(code);
    } else {
      if (donorId == null) {
        await _handleDonorScan(code);
      } else {
        await _handleRequestScan(code);
      }
    }
    
    if (mounted) setState(() => isProcessing = false);
  }

  Future<void> _handleVerifyRequest(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final adminProfile = ref.read(userProfileProvider).value;
    final myHospitalId = adminProfile?['hospitalId'];

    try {
      final doc = await FirebaseFirestore.instance.collection('blood_requests').doc(id).get();
      if (!doc.exists) throw Exception(l10n.invalidQr);

      // Security check (Task 7)
      if (doc.data()?['hospitalId'] != myHospitalId) {
        throw Exception(l10n.invalidHospital);
      }

      await doc.reference.update({'isVerified': true});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verifySuccess)));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> _handleDonorScan(String id) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (!doc.exists) throw Exception(l10n.invalidQr);

      setState(() {
        donorId = id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.donorDetected(doc.data()?['name'] ?? l10n.unknown))),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleRequestScan(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final adminProfile = ref.read(userProfileProvider).value;
    final myHospitalId = adminProfile?['hospitalId'];

    try {
      final doc = await FirebaseFirestore.instance.collection('blood_requests').doc(id).get();
      if (!doc.exists) throw Exception(l10n.invalidQr);

      // Security check (Task 7)
      if (doc.data()?['hospitalId'] != myHospitalId) {
        throw Exception(l10n.invalidHospital);
      }

      setState(() => requestId = id);
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.confirmDonationTitle),
          content: Text(l10n.confirmDonationBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm)),
          ],
        ),
      );

      if (confirm == true) {
        await _completeDonation();
      } else {
        setState(() => requestId = null);
      }
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> _completeDonation() async {
    final l10n = AppLocalizations.of(context)!;
    final adminProfile = ref.read(userProfileProvider).value;
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // 1. Update Request Status
      final requestRef = FirebaseFirestore.instance.collection('blood_requests').doc(requestId);
      batch.update(requestRef, {'status': 'done'});
      
      // 2. Update Donor's lastDonated
      final donorRef = FirebaseFirestore.instance.collection('users').doc(donorId);
      batch.update(donorRef, {'lastDonated': DateTime.now().toIso8601String()});
      
      // 3. Create Donation Record
      final donationRef = FirebaseFirestore.instance.collection('donations').doc();
      batch.set(donationRef, {
        'donorId': donorId,
        'requestId': requestId,
        'hospitalId': adminProfile?['hospitalId'],
        'hospitalName': adminProfile?['name'],
        'timestamp': FieldValue.serverTimestamp(),
        'verifiedBy': adminProfile?['uid'],
      });
      
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.donationSuccess)));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String title = widget.isVerifyOnly 
        ? l10n.verifyRequest 
        : (donorId == null ? l10n.step1Of2 : l10n.step2Of2);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.isVerifyOnly 
                    ? l10n.scanRequestQr 
                    : (donorId == null ? l10n.waitingForDonor : l10n.waitingForRequest),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          if (isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
