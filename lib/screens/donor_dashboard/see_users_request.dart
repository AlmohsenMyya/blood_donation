import 'package:sheryan/core/utils/whatsapp_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/core/utils/blood_logic.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class UsersRequestsScreen extends ConsumerStatefulWidget {
  const UsersRequestsScreen({super.key});

  @override
  ConsumerState<UsersRequestsScreen> createState() => _UsersRequestsScreenState();
}

class _UsersRequestsScreenState extends ConsumerState<UsersRequestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  List<Map<String, dynamic>> _allRequests = [];
  String? _userBloodGroup;

  @override
  void initState() {
    super.initState();
    // Get blood group from the cached profile stream — no extra Firestore call.
    ref.listenManual(
      userProfileProvider,
      (_, next) {
        final profile = next.asData?.value;
        if (profile == null) return;
        final bg = profile['bloodGroup'] as String?;
        if (bg != null && bg != _userBloodGroup) {
          _userBloodGroup = bg;
          _fetchRequests();
        }
      },
      fireImmediately: true,
    );
  }

  Future<void> _fetchRequests() async {
    if (_userBloodGroup == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() => _loading = true);

    try {
      final compatibleTypes = BloodLogic.getCompatibleRecipients(_userBloodGroup!);
      final snapshot = await _firestore
          .collection('blood_requests')
          .where('status', isEqualTo: 'pending')
          .where('bloodGroup', whereIn: compatibleTypes)
          .get();

      final requests = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      requests.sort((a, b) {
        final aMatch = a['bloodGroup'] == _userBloodGroup;
        final bMatch = b['bloodGroup'] == _userBloodGroup;
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return 0;
      });

      if (!mounted) return;
      setState(() {
        _allRequests = requests;
        _loading = false;
      });
    } catch (e) {
      debugPrint('UsersRequestsScreen._fetchRequests: $e');
      if (mounted) setState(() => _loading = false);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
          ),
        ],
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
              : RefreshIndicator(
                  onRefresh: _fetchRequests,
                  child: ListView.builder(
                    padding: AppDesignConstants.edgeInsetsMedium,
                    itemCount: _allRequests.length,
                    itemBuilder: (context, index) {
                      final request = _allRequests[index];
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
                                              const Icon(Icons.verified,
                                                  color: Colors.blue, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.statusVerified,
                                                style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPerfect
                                              ? AppColors.primaryRed
                                              : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          request['bloodGroup'] ?? '?',
                                          style: TextStyle(
                                            color: isPerfect
                                                ? Colors.white
                                                : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isPerfect)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Text('MATCH',
                                              style: TextStyle(
                                                  color: AppColors.success,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.local_hospital, l10n.hospitalName,
                                  request['hospital'] ?? ''),
                              _buildInfoRow(
                                  Icons.location_on, l10n.city, request['city'] ?? ''),
                              _buildInfoRow(Icons.invert_colors, l10n.units,
                                  request['units']?.toString() ?? ''),
                              _buildInfoRow(
                                Icons.access_time,
                                l10n.neededAtLabel(''),
                                () {
                                  final neededAt = request['neededAt'];
                                  if (neededAt == null) return l10n.notSpecified;
                                  if (neededAt is Timestamp) {
                                    return DateFormat('yyyy-MM-dd HH:mm')
                                        .format(neededAt.toDate());
                                  }
                                  if (neededAt is String) {
                                    try {
                                      final parsed =
                                          DateFormat('dd MMM yyyy, hh:mm a')
                                              .parse(neededAt);
                                      return DateFormat('yyyy-MM-dd HH:mm')
                                          .format(parsed);
                                    } catch (_) {
                                      return neededAt;
                                    }
                                  }
                                  return l10n.notSpecified;
                                }(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _callUser(request['phone'] ?? ''),
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
                                            request['patientName'] ??
                                                l10n.unknownPatient,
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
          Text('$label: ',
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      color: colorScheme.onSurface, fontSize: 13))),
        ],
      ),
    );
  }
}
