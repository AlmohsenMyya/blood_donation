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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hospitalAdminDashboard),
      ),
      body: Padding(
        padding: AppDesignConstants.edgeInsetsMedium,
        child: Column(
          children: [
            _buildActionCard(
              context,
              icon: Icons.verified_user,
              title: l10n.verifyRequest,
              color: AppColors.hospitalPrimary,
              onTap: () => _openScanner(context, isVerifyOnly: true),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              context,
              icon: Icons.handshake,
              title: l10n.registerDonation,
              color: AppColors.success,
              onTap: () => _openScanner(context, isVerifyOnly: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDesignConstants.borderRadiusMedium,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
      ),
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
    try {
      final doc = await FirebaseFirestore.instance.collection('blood_requests').doc(id).get();
      if (!doc.exists) throw Exception(l10n.invalidQr);

      await doc.reference.update({'isVerified': true});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verifySuccess)));
        Navigator.pop(context);
      }
    } catch (e) {
      _showError(e.toString());
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
    try {
      final doc = await FirebaseFirestore.instance.collection('blood_requests').doc(id).get();
      if (!doc.exists) throw Exception(l10n.invalidQr);

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
      _showError(e.toString());
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
        'hospitalName': adminProfile?['name'], // Using admin's name as fallback if hospital name isn't separate
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
