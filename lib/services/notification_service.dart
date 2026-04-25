import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/core/utils/blood_logic.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NotificationService {

  static const String _oneSignalAppId = "7f8b7b58-1638-4055-a0f9-e5f39ce121dc";
  

  static const String _restApiKey = "7f8b7b58-1638-4055-a0f9-e5f39ce121dc";

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init(BuildContext context) async {
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

  /// Sends an emergency notification to compatible donors in a city
  Future<void> sendEmergencyNotification({
    required String city,
    required String bloodGroup,
    required String requestId,
  }) async {
    if (_restApiKey == "YOUR_REST_API_KEY") {
      debugPrint("OneSignal Error: REST API Key not configured.");
      return;
    }

    final compatibleTypes = BloodLogic.getCompatibleDonors(bloodGroup);
    
    // Construct filters: (City == X AND Role == donor AND (Blood == A+ OR Blood == O+ ...))
    List<Map<String, dynamic>> filters = [
      {"field": "tag", "key": "city", "relation": "=", "value": city.toLowerCase().trim()},
      {"operator": "AND"},
      {"field": "tag", "key": "user_role", "relation": "=", "value": "donor"},
      {"operator": "AND"},
    ];

    // Add blood group filters with OR between them
    for (int i = 0; i < compatibleTypes.length; i++) {
      filters.add({
        "field": "tag", 
        "key": "blood_group", 
        "relation": "=", 
        "value": compatibleTypes[i]
      });
      if (i < compatibleTypes.length - 1) {
        filters.add({"operator": "OR"});
      }
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
    if (_restApiKey == "YOUR_REST_API_KEY") return;

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

  /// Clean tags on logout
  Future<void> logout() async {
    OneSignal.logout();
  }
}
