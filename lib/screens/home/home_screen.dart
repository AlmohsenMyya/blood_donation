
import 'package:sheryan/screens/hospital/hospital_dashboard.dart';
import 'package:sheryan/core/enums/user_role.dart';
// ...
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/screens/donor_dashboard/donor_settings.dart';
import 'package:sheryan/screens/donor_dashboard/donors_list.dart';
import 'package:sheryan/screens/donor_dashboard/donors_profile.dart';
import 'package:sheryan/screens/donor_dashboard/nearby_users_req.dart';
import 'package:sheryan/screens/donor_dashboard/see_users_request.dart';
import 'package:sheryan/screens/donors/donors_list_screen.dart';
import 'package:sheryan/screens/donors/nearby_donors_screen.dart';
import 'package:sheryan/screens/misc/awareness_screen.dart';
import 'package:sheryan/screens/profile/user_profile_screen.dart';
import 'package:sheryan/screens/requests/create_request_screen.dart';
import 'package:sheryan/screens/requests/requests_list_screen.dart';
import 'package:sheryan/screens/settings/userside_settings_screen.dart';
import 'package:sheryan/services/auth_service.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';
import 'package:sheryan/providers/locale/locale_provider.dart';
import 'package:sheryan/screens/auth/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool loading = true;
  int _selectedTab = 0;
  String _currentQuote = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => loading = true);
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc = await _fs.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        userData = doc.data();
        // Sync role provider if needed
        final roleStr = userData?['role'];
        if (roleStr != null) {
          ref.read(roleProvider.notifier).setRoleFromString(roleStr);
        }
      }
    }
    if (mounted) {
       final l10n = AppLocalizations.of(context)!;
       final List<String> quotes = [
        l10n.quote1,
        l10n.quote2,
        l10n.quote3,
        l10n.quote4,
        l10n.quote5,
        l10n.quote6,
        l10n.quote7,
      ];
      _currentQuote = (quotes..shuffle()).first;
    }
    setState(() => loading = false);
  }

  Future<void> _signOutAndGoLogin() async {
    try {
      await ref.read(authServiceProvider).logoutUser();
    } catch (_) {
      await AuthService().logoutUser();
    }
    ref.read(roleProvider.notifier).clearRole();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _showLanguageSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = ref.read(localeProvider)?.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDesignConstants.radiusExtraLarge)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.changeLanguage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                title: Text(
                  l10n.languageEnglish,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: currentCode == 'en'
                    ? const Icon(Icons.check, color: AppColors.primaryRed)
                    : null,
                onTap: () async {
                  await ref.read(localeProvider.notifier).setLocale(
                    const Locale('en'),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦', style: TextStyle(fontSize: 20)),
                title: Text(
                  l10n.languageArabic,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: currentCode == 'ar'
                    ? const Icon(Icons.check, color: AppColors.primaryRed)
                    : null,
                onTap: () async {
                  await ref.read(localeProvider.notifier).setLocale(
                    const Locale('ar'),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _topAppBar(UserRole role) {
  final l10n = AppLocalizations.of(context)!;
  String title = l10n.appTitle;
  if (role == UserRole.donor) title = l10n.donorDashboard;
  if (role == UserRole.hospitalAdmin) title = l10n.hospitalAdminDashboard;

  return AppBar(
    title: Text(title),
    actions: [
      IconButton(
        tooltip: l10n.changeLanguage,
        icon: const Icon(Icons.language),
        onPressed: _showLanguageSheet,
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.settings ),
        onSelected: (v) {
          if (v == 'settings') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => role == UserRole.donor
                    ? const DonorSettingsScreen()
                    : const SettingsScreen(),
              ),
            );
          } else if (v == 'logout') {
            _signOutAndGoLogin();
          }
        },
        itemBuilder: (ctx) => [
           if (role != UserRole.hospitalAdmin)
           PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                const Icon(Icons.settings, color: Colors.black54),
                const SizedBox(width: 8),
                Text(l10n.settings),
              ],
            ),
          ),
           PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.black54),
                const SizedBox(width: 8),
                Text(l10n.logout),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _statCard(String title, String value) {
    return Container(
      padding: AppDesignConstants.edgeInsetsMedium,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppDesignConstants.borderRadiusMedium,
        border: Border.all(color: Colors.grey.shade900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _greeting() {
    final l10n = AppLocalizations.of(context)!;
    final name = userData?['name'] ?? l10n.friend;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning
        : hour < 18
        ? l10n.goodAfternoon
        : l10n.goodEvening;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting,', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
        ),
      ],
    );
  }
  Widget _buildmotivationalCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        subtitle: Text(
          subtitle, 
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        ),
    );
  }

  Widget _buildCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryRed,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textGrey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBody(UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    if (loading) return const Center(child: CircularProgressIndicator());

    if (role == UserRole.donor) {
      return RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDesignConstants.edgeInsetsMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _greeting(),

              const SizedBox(height: 10,),
              _buildmotivationalCard(
                Icons.emoji_events,
                l10n.motivationTitle,
                _currentQuote,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      l10n.bloodGroup,
                      userData?['bloodGroup'] ?? '-',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(l10n.city, userData?['city'] ?? '-')),
                ],
              ),
              
              const SizedBox(height: 18),
              Card(
                child: InkWell(
                  borderRadius: AppDesignConstants.borderRadiusMedium,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersRequestsScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(
                      Icons.bloodtype_rounded,
                      color: AppColors.primaryRed,
                    ),
                    title: Text(
                      l10n.usersBloodRequests,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      l10n.viewAllRequestsFromUsersAcross,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                   borderRadius: AppDesignConstants.borderRadiusMedium,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NearbyRequestsScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(Icons.bloodtype, color: AppColors.primaryRed),
                    title: Text(
                      l10n.nearbyRequests,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      l10n.checkNearbyBloodRequests,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: InkWell(
                  borderRadius: AppDesignConstants.borderRadiusMedium,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TipsScreen()),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(
                      Icons.tips_and_updates,
                      color: AppColors.primaryRed,
                    ),
                    title: Text(
                      l10n.awareness,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      l10n.awarenessDonorSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDesignConstants.edgeInsetsMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _greeting(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      l10n.bloodGroup,
                      userData?['bloodGroup'] ?? '-',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard(l10n.city, userData?['city'] ?? '-')),
                ],
              ),
              const SizedBox(height: 18),
              _buildCard(
                Icons.bloodtype,
                l10n.requestBlood,
                l10n.createNewBloodRequest,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestBloodScreen()),
                ),
              ),
              _buildCard(
                Icons.favorite_outline,
                l10n.myRequests,
                l10n.trackPreviousRequests,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestsListScreen()),
                ),
              ),
              _buildCard(
                Icons.near_me,
                l10n.nearbyDonors,
                l10n.trackNearbyDonors,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NearbyDonorsScreen()),
                ),
              ),
              _buildCard(
                Icons.tips_and_updates,
                l10n.awareness,
                l10n.awarenessUserSubtitle,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TipsScreen()),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(roleProvider) ?? 
                 (userData?['role'] == 'donor' ? UserRole.donor : UserRole.recipient);
    final l10n = AppLocalizations.of(context)!;

    // Handle Admin Roles specifically
    if (role == UserRole.hospitalAdmin) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _topAppBar(role),
        ),
        body: const HospitalDashboard(),
      );
    }

    if (role == UserRole.superAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("Super Admin")),
        body: const Center(child: Text("Super Admin Dashboard Coming Soon")),
        floatingActionButton: FloatingActionButton(
          onPressed: _signOutAndGoLogin,
          child: const Icon(Icons.logout),
        ),
      );
    }

    // Role-based tabs
    final List<Widget> tabs = [
      _buildBody(role),
      if (role == UserRole.recipient) const DonorListScreen(),
      if (role == UserRole.recipient) const ProfileScreen(),
      if (role == UserRole.donor) const DonorsList(), 
       if (role == UserRole.donor) const DonorProfileScreen(),
    ];

    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.homeTab),
      if (role == UserRole.recipient)
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: l10n.donorsTab,
        ),
      if (role == UserRole.recipient)
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n.profileTab,
        ),

      if (role == UserRole.donor)
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_3),
          label: l10n.allDonorsTab,
        ),
        if (role == UserRole.donor)
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_3),
          label: l10n.profileTab,
        ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _topAppBar(role),
      ),
      body: tabs[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        items: items,
      ),
    );
  }
}