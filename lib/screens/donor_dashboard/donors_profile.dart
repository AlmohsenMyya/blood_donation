import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/core/utils/profile_completion.dart';
import 'package:sheryan/core/utils/qr_dialog.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/screens/donor_dashboard/blood_compatibility_screen.dart';
import 'package:sheryan/screens/donor_dashboard/donation_history_screen.dart';
import 'package:sheryan/screens/donor_dashboard/profile_sections/emergency_contact_screen.dart';
import 'package:sheryan/screens/donor_dashboard/profile_sections/health_info_screen.dart';
import 'package:sheryan/screens/donor_dashboard/profile_sections/medical_history_screen.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _userData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!mounted) return;
    setState(() {
      _userData = doc.data() ?? {};
      _loading = false;
    });
  }

  Future<void> _navigateToSection(Widget screen) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (result == true) await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completion = ProfileCompletion.calculate(_userData);
    final sections = ProfileCompletion.getSections(_userData);
    final isVerified = ProfileCompletion.bloodVerified(_userData);
    final name = _userData['name'] ?? l10n.bloodDonor;
    final bloodGroup = _userData['bloodGroup'] ?? l10n.notAvailable;
    final city = _userData['city'] ?? l10n.unknownCity;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primaryRed,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(
                  name, bloodGroup, city, isVerified, completion, l10n, theme),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.profileSections,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
              const SizedBox(height: 8),

              ...sections.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                final title = isAr ? s.titleAr : s.titleEn;
                final subtitle = isAr ? s.subtitleAr : s.subtitleEn;
                return _buildSectionCard(
                  context: context,
                  index: i,
                  title: title,
                  subtitle: subtitle,
                  weight: s.weight,
                  isComplete: s.isComplete,
                  requiresHospital: s.requiresHospital,
                  l10n: l10n,
                  theme: theme,
                  onTap: s.requiresHospital || i == 0
                      ? null
                      : () => _navigateToSection(
                            _screenForIndex(i, _userData),
                          ),
                );
              }),

              const SizedBox(height: 16),

              _buildDonationHistoryCard(l10n, theme),

              const SizedBox(height: 5),

              _buildCompatibilityCard(bloodGroup, l10n, theme),

              const SizedBox(height: 4),

              Padding(
                padding: AppDesignConstants.edgeInsetsMedium,
                child: OutlinedButton.icon(
                  onPressed: () => QrDialog.show(
                    context,
                    data: user.uid,
                    label: name,
                    idLabel: l10n.donorId,
                  ),
                  icon: const Icon(Icons.qr_code),
                  label: Text(l10n.donorCard),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    String name,
    String bloodGroup,
    String city,
    bool isVerified,
    int completion,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.accentRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.bloodtype,
                      size: 36, color: AppColors.primaryRed),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(bloodGroup,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 3),
                                  Text(l10n.verified,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(city,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.profileCompletion,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text('$completion%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completion / 100,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completion >= 80
                      ? Colors.greenAccent
                      : completion >= 50
                          ? Colors.yellowAccent
                          : Colors.white,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _completionMessage(completion, l10n),
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _completionMessage(int pct, AppLocalizations l10n) {
    if (pct == 100) return l10n.completionFull;
    if (pct >= 65) return l10n.completionGood;
    if (pct >= 35) return l10n.completionPartial;
    return l10n.completionLow;
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required int weight,
    required bool isComplete,
    required bool requiresHospital,
    required AppLocalizations l10n,
    required ThemeData theme,
    VoidCallback? onTap,
  }) {
    final iconData = _iconForIndex(index);
    final Color statusColor =
        isComplete ? AppColors.success : theme.colorScheme.onSurface.withOpacity(0.5);
    final Color borderColor = isComplete
        ? AppColors.success.withOpacity(0.4)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.success.withOpacity(0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(iconData, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isComplete
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.success.withOpacity(0.12)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$weight%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isComplete
                            ? AppColors.success
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isComplete)
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 18)
                  else if (requiresHospital)
                    const Icon(Icons.local_hospital_outlined,
                        color: Colors.blue, size: 18)
                  else
                    Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withOpacity(0.5), size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityCard(
      String bloodGroup, AppLocalizations l10n, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BloodCompatibilityScreen(donorBloodGroup: bloodGroup),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(0.18),
              Colors.deepPurple.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.deepPurple.withOpacity(0.3), width: 1.2),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.bloodtype_outlined,
                    color: Colors.deepPurple, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.bloodCompatibilityTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(l10n.viewCompatibilityGuide,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Colors.deepPurple, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationHistoryCard(AppLocalizations l10n, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const DonationHistoryScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryRed.withOpacity(0.18),
              AppColors.accentRed.withOpacity(0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primaryRed.withOpacity(0.3), width: 1.2),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.favorite,
                    color: AppColors.primaryRed, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.donationHistory,
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(l10n.viewDonationHistory,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.primaryRed, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForIndex(int i) {
    switch (i) {
      case 0:
        return Icons.person_outline;
      case 1:
        return Icons.monitor_weight_outlined;
      case 2:
        return Icons.medical_services_outlined;
      case 3:
        return Icons.contact_phone_outlined;
      case 4:
        return Icons.verified_user_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _screenForIndex(int index, Map<String, dynamic> data) {
    switch (index) {
      case 1:
        return HealthInfoScreen(existingData: data);
      case 2:
        return MedicalHistoryScreen(existingData: data);
      case 3:
        return EmergencyContactScreen(existingData: data);
      default:
        return const SizedBox.shrink();
    }
  }
}
