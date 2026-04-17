
import 'package:sheryan/providers/auth/auth_provider.dart';
import 'package:sheryan/screens/auth/sign_in_screen.dart';
import 'package:sheryan/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});


  void _onRoleTap(BuildContext context, WidgetRef ref, String role) {
  // Save role using provider (no async/await needed)
  ref.read(roleProvider.notifier).setRole(role);

  // Navigate to role-specific signup
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => SignupScreen(role: role)),
  );
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.roleWhoAreYou, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.roleSelectContinue, style: const TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoleCard(
                      icon: Icons.bloodtype,
                      title: l10n.roleDonor,
                      subtitle: l10n.roleDonorSubtitle,
                      onTap: () => _onRoleTap(context, ref, 'donor'),
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      icon: Icons.person,
                      title: l10n.roleUser,
                      subtitle: l10n.roleUserSubtitle,
                      onTap: () => _onRoleTap(context, ref, 'user'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // If user already has saved role and wants to login directly:
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: Text(l10n.alreadyHaveAccountLogin, style: const TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            Icon(icon, size: 34, color: Colors.red),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ])),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
