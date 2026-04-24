import 'package:flutter_riverpod/legacy.dart';
import 'package:sheryan/core/enums/user_role.dart';
import 'package:sheryan/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provides a single instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Listens to authentication state changes from Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Holds the selected role
final roleProvider = StateNotifierProvider<RoleNotifier, UserRole?>(
  (ref) => RoleNotifier(),
);

class RoleNotifier extends StateNotifier<UserRole?> {
  RoleNotifier() : super(null);

  /// Set selected role
  void setRole(UserRole role) => state = role;

  /// Set role from string (useful for Firebase integration)
  void setRoleFromString(String? roleStr) {
    if (roleStr == 'donor') {
      state = UserRole.donor;
    } else if (roleStr == 'user' || roleStr == 'recipient') {
      state = UserRole.recipient;
    } else if (roleStr == 'hospitalAdmin') {
      state = UserRole.hospitalAdmin;
    } else if (roleStr == 'superAdmin') {
      state = UserRole.superAdmin;
    } else {
      state = null;
    }
  }

  /// Clear selected role (used on logout)
  void clearRole() => state = null;
}