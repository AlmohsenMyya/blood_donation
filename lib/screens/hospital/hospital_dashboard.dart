import 'package:sheryan/services/notification_service.dart';
import 'package:sheryan/core/models/app_notification.dart';
import 'package:flutter/material.dart';
// ...
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        context,
                        icon: Icons.verified_user,
                        title: l10n.verifyRequest,
                        color: Theme.of(context).colorScheme.primary,
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionBtn(
                    context,
                    icon: Icons.bloodtype,
                    title: l10n.verifyDonorBloodGroup,
                    color: Colors.deepPurple,
                    onTap: () => _openBloodGroupVerification(context),
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
                Icon(Icons.list_alt, color: Theme.of(context).colorScheme.primary),
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
                                    isDone 
                                      ? l10n.statusCompleted 
                                      : (isVerified ? l10n.statusVerified : l10n.statusUnverified),
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

  void _openBloodGroupVerification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BloodGroupVerificationScreen(),
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
      
      final requestData = doc.data() as Map<String, dynamic>;
      final requesterId = requestData['userId'];

      // 1. Notify the Requester
      if (requesterId != null) {
        NotificationService().sendDirectNotification(
          targetUid: requesterId,
          titleEn: "Request Verified!",
          titleAr: "تم توثيق طلبك!",
          bodyEn: "Your blood request has been verified and broadcasted to donors. 🏥",
          bodyAr: "تم توثيق طلب الدم الخاص بك وتعميمه على المتبرعين. 🏥",
        );
      }

      // 2. Broadcast to Compatible Donors
      NotificationService().sendEmergencyNotification(
        city: requestData['city'] ?? '',
        bloodGroup: requestData['bloodGroup'] ?? '',
        requestId: id,
      );

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

      // Trigger Gratitude Notifications (Phase 3)
      final requestDoc = await FirebaseFirestore.instance.collection('blood_requests').doc(requestId).get();
      final recipientUid = requestDoc.data()?['userId'];

      if (donorId != null) {
        NotificationService().sendDirectNotification(
          targetUid: donorId!,
          titleEn: "Donation Successful!",
          titleAr: "تم التبرع بنجاح!",
          bodyEn: "Thank you for your generous donation. You saved a life today! 🩸",
          bodyAr: "شكراً لعطائك. لقد ساهمت في إنقاذ حياة اليوم! 🩸",
        );
      }

      if (recipientUid != null) {
        NotificationService().sendDirectNotification(
          targetUid: recipientUid,
          titleEn: "Request Fulfilled!",
          titleAr: "تم تلبية طلبك!",
          bodyEn: "Good news! A successful donation has been registered for your request.",
          bodyAr: "بشرى سارة! تم تسجيل عملية تبرع ناجحة لطلبك.",
        );
      }

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

// ─── Blood Group Verification Screen ────────────────────────────────────────

class BloodGroupVerificationScreen extends ConsumerStatefulWidget {
  const BloodGroupVerificationScreen({super.key});

  @override
  ConsumerState<BloodGroupVerificationScreen> createState() =>
      _BloodGroupVerificationScreenState();
}

class _BloodGroupVerificationScreenState
    extends ConsumerState<BloodGroupVerificationScreen> {
  bool _isProcessing = false;
  Map<String, dynamic>? _scannedDonor;
  String? _scannedDonorId;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _scannedDonor != null) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(code)
          .get();

      if (!doc.exists) throw Exception('Invalid QR code');

      final data = doc.data()!;
      if (data['role'] != 'donor') {
        throw Exception('This QR does not belong to a donor');
      }

      setState(() {
        _scannedDonorId = code;
        _scannedDonor = data;
      });

      if (mounted) await _showVerificationDialog(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showVerificationDialog(Map<String, dynamic> donor) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final alreadyVerified = donor['bloodGroupVerified'] == true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: AppDesignConstants.borderRadiusLarge),
        title: Text(l10n.bloodGroupVerificationTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alreadyVerified)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.bloodGroupAlreadyVerified,
                        style:
                            const TextStyle(color: AppColors.success)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _infoRow(Icons.person, l10n.name, donor['name'] ?? '—'),
            const SizedBox(height: 8),
            _infoRow(Icons.bloodtype, l10n.bloodGroup,
                donor['bloodGroup'] ?? '—'),
            const SizedBox(height: 8),
            _infoRow(Icons.location_city, l10n.city, donor['city'] ?? '—'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            icon: const Icon(Icons.verified, size: 18),
            label: Text(l10n.confirmBloodGroupVerification),
          ),
        ],
      ),
    );

    if (confirm == true) await _verify(donor);
    setState(() => _scannedDonor = null);
  }

  Future<void> _verify(Map<String, dynamic> donor) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_scannedDonorId)
          .update({'bloodGroupVerified': true});

      NotificationService().sendDirectNotification(
        targetUid: _scannedDonorId!,
        titleEn: 'Blood Group Verified ✅',
        titleAr: 'تم توثيق زمرة دمك ✅',
        bodyEn:
            'Your blood group (${donor['bloodGroup']}) has been medically verified. Your profile completion increased!',
        bodyAr:
            'تم توثيق زمرة دمك (${donor['bloodGroup']}) طبياً من قِبل المستشفى. اكتمال ملفك ازداد!',
        type: NotificationType.verification,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bloodGroupVerifiedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyDonorBloodGroup),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurpleAccent, width: 2.5),
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
                l10n.scanDonorQrForVerification,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
