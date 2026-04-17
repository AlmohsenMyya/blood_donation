

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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> motivationalQuotes = [
    "Your single act can save lives.",
    "Be the reason someone survives today.",
    "Every drop counts — donate blood.",
    "Giving blood is giving hope.",
    "Heroes don’t wear capes, they donate blood.",
    "You can make a difference today.",
    "One call, one donation, one life saved.",
  ];
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool loading = true;
  int _selectedTab = 0;
  String _currentQuote = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _currentQuote = (motivationalQuotes..shuffle()).first;
  }

  Future<void> _loadUser() async {
    setState(() => loading = true);
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc = await _fs.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        userData = doc.data();
      }
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
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.changeLanguage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                title: Text(
                  l10n.languageEnglish,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: currentCode == 'en'
                    ? const Icon(Icons.check, color: Colors.red)
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
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: currentCode == 'ar'
                    ? const Icon(Icons.check, color: Colors.red)
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

  Widget _topAppBar(String role) {
  final l10n = AppLocalizations.of(context)!;
  return AppBar(
    backgroundColor: Colors.black,
    elevation: 0,
    title: Text(
      role == 'donor' ? l10n.donorDashboard : l10n.appTitle,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    actions: [
      IconButton(
        tooltip: l10n.changeLanguage,
        icon: const Icon(Icons.language, color: Colors.white),
        onPressed: _showLanguageSheet,
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.settings, color: Colors.white),
        onSelected: (v) {
          if (v == 'settings') {
            // ✅ Open different Settings screens based on role
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => role == 'donor'
                    ? const DonorSettingsScreen()
                    : const SettingsScreen(),
              ),
            );
          } else if (v == 'logout') {
            _signOutAndGoLogin();
          }
        },
        itemBuilder: (ctx) => [
          // ✅ Show Settings for both roles now
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.black54),
                SizedBox(width: 8),
                Text(l10n.settings),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.black54),
                SizedBox(width: 8),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
        Text('$greeting,', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
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
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        // leading: CircleAvatar(
        //   backgroundColor: Colors.red.shade700,
        //   child: Icon(icon, color: Colors.white),
        // ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey),textAlign: TextAlign.center,),
        // trailing: const Icon(
        //   Icons.arrow_forward_ios,
        //   color: Colors.grey,
        //   size: 16,
        ),
       // onTap: onTap,
      
    );
  }

  Widget _buildCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade700,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBody(String role) {
    final l10n = AppLocalizations.of(context)!;
    if (loading) return const Center(child: CircularProgressIndicator());

    if (role == 'donor') {
      return RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _greeting(),

              SizedBox(height: 10,),
              _buildmotivationalCard(
                Icons.emoji_events,
                l10n.motivationTitle,
                _currentQuote,
                onTap: () {
                  // Refresh quote on tap
                  // setState(() {
                  //   _currentQuote = (motivationalQuotes..shuffle()).first;
                  // });
                },
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
                color: const Color(0xFF0F0F0F),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsersRequestsScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(
                      Icons.bloodtype_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      l10n.usersBloodRequests,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      l10n.viewAllRequestsFromUsersAcross,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NearbyRequestsScreen(),
                    ),
                  );
                },
                child: Card(
                  color: const Color(0xFF0F0F0F),
                  child: ListTile(
                    leading: const Icon(Icons.bloodtype, color: Colors.red),
                    title: Text(
                      l10n.nearbyRequests,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      l10n.checkNearbyBloodRequests,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TipsScreen()),
                  );
                },
                child: Card(
                  color: const Color(0xFF0F0F0F),
                  child: ListTile(
                    leading: const Icon(
                      Icons.tips_and_updates,
                      color: Colors.red,
                    ),
                    title: Text(
                      l10n.awareness,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      l10n.awarenessDonorSubtitle,
                      style: TextStyle(color: Colors.grey),
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
          padding: const EdgeInsets.all(18),
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
    final role = ref.watch(roleProvider) ?? userData?['role'] ?? 'user';
    final l10n = AppLocalizations.of(context)!;


    // Role-based tabs
    final List<Widget> tabs = [
      _buildBody(role),
      if (role == 'user') const DonorListScreen(),
      if (role == 'user') const ProfileScreen(),
      if (role == 'donor') const DonorsList(), 
       if (role == 'donor') const DonorProfileScreen(),
    ];

    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.homeTab),
      if (role == 'user')
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: l10n.donorsTab,
        ),
      if (role == 'user')
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n.profileTab,
        ),

      if (role == 'donor')
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_3),
          label: l10n.allDonorsTab,
        ),
        if (role == 'donor')
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
        backgroundColor: Colors.black,
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: items,
      ),
    );
  }
}
