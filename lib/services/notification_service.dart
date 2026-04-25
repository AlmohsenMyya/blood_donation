import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NotificationService {

  static const String _oneSignalAppId = "7f8b7b58-1638-4055-a0f9-e5f39ce121dc";

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init(BuildContext context) async {
    // 1. Debugging (Optional)
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // 2. Initialize OneSignal
    OneSignal.initialize(_oneSignalAppId);

    // 3. Request permissions ( لبق )
    await _requestPermissions(context);

    // 4. Handle Notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Custom handling of foreground notifications if needed
    });
  }

  Future<void> _requestPermissions(BuildContext context) async {
    bool canRequest = await OneSignal.Notifications.canRequest();
    
    if (canRequest) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        bool? startRequest = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.notificationPermissionTitle),
            content: Text(l10n.notificationPermissionBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.later)),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.allow)),
            ],
          ),
        );

        if (startRequest == true) {
          await OneSignal.Notifications.requestPermission(true);
        }
      }
    }
  }

  /// Sends user data to OneSignal as Tags for "Smart Matching"
  Future<void> sendUserTags({
    required String uid,
    required String city,
    required String bloodGroup,
    required String role,
  }) async {
    // Set External User ID to match Firestore UID
    OneSignal.login(uid);

    // Send Tags
    OneSignal.User.addTags({
      "city": city.toLowerCase().trim(),
      "blood_group": bloodGroup.trim(),
      "user_role": role.trim(),
    });
  }

  /// Clean tags on logout
  Future<void> logout() async {
    OneSignal.logout();
  }
}
