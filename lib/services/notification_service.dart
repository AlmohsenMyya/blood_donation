import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheryan/core/utils/blood_logic.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NotificationService {
  static const String _oneSignalAppId = "7f8b7b58-1638-4055-a0f9-e5f39ce121dc";
  
  // REST API Key from OneSignal Dashboard -> Settings -> API Keys
  static const String _restApiKey = "os_v2_app_p6fxwwawhbaflihz4xzzzyjb3rmqjf2bgpneetf2br5mqwhpu5hwbyvufsjubohe7mw2dttpx6epy47avktj22nzvrlphfpuceb3xhi";

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _prefKeyPermissionRequested = "notification_permission_requested";
  static const String _prefKeyEnabled = "notification_enabled";

  Future<void> init(BuildContext context) async {
    OneSignal.initialize(_oneSignalAppId);
    
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool(_prefKeyEnabled) ?? true;

    if (isEnabled) {
      OneSignal.User.pushSubscription.optIn();
      bool alreadyRequested = prefs.getBool(_prefKeyPermissionRequested) ?? false;
      if (!alreadyRequested) await _requestPermissions(context);
    } else {
      OneSignal.User.pushSubscription.optOut();
    }

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });
  }

  Future<void> _requestPermissions(BuildContext context) async {
    bool canRequest = await OneSignal.Notifications.canRequest();
    if (canRequest && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      bool? startRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.notificationPermissionTitle),
          content: Text(l10n.notificationPermissionBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.later)),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.allow)),
          ],
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyPermissionRequested, true);
      if (startRequest == true) {
        await OneSignal.Notifications.requestPermission(true);
        await setNotificationEnabled(true);
      } else {
        await setNotificationEnabled(false);
      }
    }
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);
    if (enabled) {
      OneSignal.User.pushSubscription.optIn();
    } else {
      OneSignal.User.pushSubscription.optOut();
    }
  }

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyEnabled) ?? true;
  }

  Future<void> sendUserTags({
    required String uid,
    required String city,
    required String bloodGroup,
    required String role,
  }) async {
    final enabled = await isNotificationEnabled();
    if (!enabled) return;
    OneSignal.login(uid);
    OneSignal.User.addTags({
      "city": city.toLowerCase().trim(),
      "blood_group": bloodGroup.trim(),
      "user_role": role.trim(),
    });
  }

  Future<void> sendEmergencyNotification({
    required String city,
    required String bloodGroup,
    required String requestId,
  }) async {
    final compatibleTypes = BloodLogic.getCompatibleDonors(bloodGroup);
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

    final payload = {
      "app_id": _oneSignalAppId,
      "contents": {
        "en": "🆘 Urgent! $bloodGroup needed in $city. Donate now!",
        "ar": "🆘 نداء عاجل! فصيلة $bloodGroup مطلوبة في $city. ساهم في الإنقاذ الآن!"
      },
      "headings": {"en": "Emergency Blood Request", "ar": "طلب دم طارئ"},
      "filters": filters,
      "data": {"requestId": requestId, "type": "emergency"}
    };

    await _sendNotification(payload);
  }

  Future<void> sendDirectNotification({
    required String targetUid,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
  }) async {
    final payload = {
      "app_id": _oneSignalAppId,
      "include_external_user_ids": [targetUid],
      "contents": {"en": bodyEn, "ar": bodyAr},
      "headings": {"en": titleEn, "ar": titleAr},
    };

    await _sendNotification(payload);
  }

  Future<void> _sendNotification(Map<String, dynamic> payload) async {
    try {
      print("🚀 [OneSignal] Sending Request...");
      final response = await http.post(
        Uri.parse("https://api.onesignal.com/notifications"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Key $_restApiKey"
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [OneSignal] Success: ${response.body}");
      } else {
        print("❌ [OneSignal] Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("⚠️ [OneSignal] Exception: $e");
    }
  }

  Future<void> logout() async {
    OneSignal.logout();
  }
}
