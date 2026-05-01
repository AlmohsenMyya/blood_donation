import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheryan/core/utils/blood_logic.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NotificationService {
  // --- Replace with your actual REST API Key from OneSignal Dashboard ---
  static const String _oneSignalAppId = "7f8b7b58-1638-4055-a0f9-e5f39ce121dc";
  
  // CRITICAL: This MUST be the REST API Key, not the App ID.
  // Find it in OneSignal -> Settings -> API Keys -> REST API Key
  static const String _restApiKey = "os_v2_app_p6fxwwawhbaflihz4xzzzyjb3qqpxampctfem6nw2cuwllw4k4duo3kabiaqqrforcyfbm7emp7gyvyx7zvtrus4rqxd2xz5csovjty";

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _prefKeyPermissionRequested = "notification_permission_requested";
  static const String _prefKeyEnabled = "notification_enabled";

  Future<void> init(BuildContext context) async {
    // 1. Initialize OneSignal
    OneSignal.initialize(_oneSignalAppId);

    // 2. Load settings from Local Storage
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool(_prefKeyEnabled) ?? true;

    if (isEnabled) {
      OneSignal.User.pushSubscription.optIn();
      
      // 3. Check if we should show the custom permission dialog (only once per install)
      bool alreadyRequested = prefs.getBool(_prefKeyPermissionRequested) ?? false;
      if (!alreadyRequested) {
        await _requestPermissions(context);
      }
    } else {
      // If user disabled it in app settings, ensure they are opted out in OneSignal
      OneSignal.User.pushSubscription.optOut();
    }

    // 4. Handle Notifications in Foreground
    // This ensures the notification banner shows even when the app is open.
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });
  }

  Future<void> _requestPermissions(BuildContext context) async {
    // canRequest() returns true if the system hasn't permanently denied permission
    bool canRequest = await OneSignal.Notifications.canRequest();
    
    if (canRequest) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        
        // Custom UI dialog to explain why we need notifications
        bool? startRequest = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.notificationPermissionTitle),
            content: Text(l10n.notificationPermissionBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false), 
                child: Text(l10n.later)
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true), 
                child: Text(l10n.allow)
              ),
            ],
          ),
        );

        // Save that we have shown this dialog
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyPermissionRequested, true);

        if (startRequest == true) {
          // Trigger the system permission prompt
          await OneSignal.Notifications.requestPermission(true);
          await setNotificationEnabled(true);
        } else {
          // User said "Later", we opt out for now
          await setNotificationEnabled(false);
        }
      }
    }
  }

  /// Toggle notifications on/off from settings
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);
    
    if (enabled) {
      OneSignal.User.pushSubscription.optIn();
      // Also request system permission if not already granted
      OneSignal.Notifications.requestPermission(true);
    } else {
      OneSignal.User.pushSubscription.optOut();
      // Optionally remove tags to stop matching logic on OneSignal side
      OneSignal.User.removeTag("city");
      OneSignal.User.removeTag("blood_group");
      OneSignal.User.removeTag("user_role");
    }
  }

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if never set, or sync with OneSignal status
    return prefs.getBool(_prefKeyEnabled) ?? (OneSignal.User.pushSubscription.optedIn ?? true);
  }

  /// Sends user data to OneSignal as Tags for "Smart Matching"
  Future<void> sendUserTags({
    required String uid,
    required String city,
    required String bloodGroup,
    required String role,
  }) async {
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    // Login to link the user ID (External ID)
    OneSignal.login(uid);

    // Send Tags for targeted notifications
    OneSignal.User.addTags({
      "city": city.toLowerCase().trim(),
      "blood_group": bloodGroup.trim(),
      "user_role": role.trim(),
    });
  }

  /// Sends an emergency notification to compatible donors in a city
  Future<void> sendEmergencyNotification({
    required String city,
    required String bloodGroup,
    required String requestId,
  }) async {
    // Security check for API Key
    if (_restApiKey == "YOUR_ACTUAL_REST_API_KEY_HERE" || _restApiKey.isEmpty) {
      debugPrint("OneSignal Error: REST API Key not configured in NotificationService.");
      return;
    }

    final compatibleTypes = BloodLogic.getCompatibleDonors(bloodGroup);
    
    // Corrected Logic: Priority-based filtering. 
    // We group City+Role+Blood into atomic filter sets joined by OR.
    List<Map<String, dynamic>> filters = [];

    for (int i = 0; i < compatibleTypes.length; i++) {
      if (i > 0) filters.add({"operator": "OR"});
      
      filters.addAll([
        {"field": "tag", "key": "city", "relation": "=", "value": city.toLowerCase().trim()},
        {"operator": "AND"},
        {"field": "tag", "key": "user_role", "relation": "=", "value": "donor"},
        {"operator": "AND"},
        {"field": "tag", "key": "blood_group", "relation": "=", "value": compatibleTypes[i]},
      ]);
    }

    final Map<String, dynamic> payload = {
      "app_id": _oneSignalAppId,
      "contents": {
        "en": "🆘 Urgent! $bloodGroup needed in $city. Donate now!",
        "ar": "🆘 نداء عاجل! فصيلة $bloodGroup مطلوبة في $city. ساهم في الإنقاذ الآن!"
      },
      "headings": {
        "en": "Emergency Blood Request",
        "ar": "طلب دم طارئ"
      },
      "filters": filters,
      "data": {
        "requestId": requestId,
        "type": "emergency"
      }
    };

    try {
      final response = await http.post(
        Uri.parse("https://onesignal.com/api/v1/notifications"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic $_restApiKey"
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        debugPrint("OneSignal Notification sent successfully.");
      } else {
        debugPrint("OneSignal Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("OneSignal Request failed: $e");
    }
  }

  /// Sends a direct notification to a specific user by their UID
  Future<void> sendDirectNotification({
    required String targetUid,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
  }) async {
    if (_restApiKey == "YOUR_ACTUAL_REST_API_KEY_HERE" || _restApiKey.isEmpty) return;

    final Map<String, dynamic> payload = {
      "app_id": _oneSignalAppId,
      "include_external_user_ids": [targetUid],
      "contents": {
        "en": bodyEn,
        "ar": bodyAr
      },
      "headings": {
        "en": titleEn,
        "ar": titleAr
      },
    };

    try {
      await http.post(
        Uri.parse("https://onesignal.com/api/v1/notifications"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic $_restApiKey"
        },
        body: jsonEncode(payload),
      );
    } catch (e) {
      debugPrint("OneSignal Direct Request failed: $e");
    }
  }

  /// Clean up on logout
  Future<void> logout() async {
    OneSignal.logout();
  }
}
