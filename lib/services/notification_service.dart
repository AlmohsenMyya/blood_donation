import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheryan/core/models/app_notification.dart';
import 'package:sheryan/core/utils/blood_logic.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'notification_secrets.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  // Local Notifications Plugin for Foreground Display
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _prefKeyPermissionRequested = "notification_permission_requested";
  static const String _prefKeyEnabled = "notification_enabled";

  // Android Notification Channel for High Importance
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', 
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );
  final Map<String, dynamic> _serviceAccount = NotificationSecrets.serviceAccount;

  Future<String?> _getAccessToken() async {
    try {
      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(_serviceAccount),
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );
      return client.credentials.accessToken.data;
    } catch (e) {
      debugPrint("❌ [FCM-DEBUG] Access Token Error: $e");
      return null;
    }
  }

  Future<void> init(BuildContext context) async {
    // 1. Setup Local Notifications for Foreground
    await _setupLocalNotifications();

    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool(_prefKeyEnabled) ?? true;

    if (isEnabled) {
      bool alreadyRequested = prefs.getBool(_prefKeyPermissionRequested) ?? false;
      if (!alreadyRequested) await _requestPermissions(context);
    }

    // 2. Setup Listeners
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🚀 [FCM] Message received in foreground: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🚀 [FCM] App opened from notification: ${message.data}");
    });
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Create the channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    if (context.mounted) {
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
        await _fcm.requestPermission(alert: true, badge: true, sound: true);
        await setNotificationEnabled(true);
      } else {
        await setNotificationEnabled(false);
      }
    }
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);
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

    String safeCity = city.toLowerCase().trim().replaceAll(' ', '_');
    String safeBlood = bloodGroup.replaceAll('+', '_pos').replaceAll('-', '_neg');
    
    debugPrint("🔍 [FCM-DEBUG] Subscribing to Topics: city_$safeCity, blood_$safeBlood, role_$role");
    await _fcm.subscribeToTopic("city_$safeCity");
    await _fcm.subscribeToTopic("blood_$safeBlood");
    await _fcm.subscribeToTopic("role_$role");
  }

  Future<void> sendEmergencyNotification({
    required String city,
    required String bloodGroup,
    required String requestId,
  }) async {
    debugPrint("🔍 [FCM-DEBUG] Emergency Notification started for City: $city");
    
    final compatibleTypes = BloodLogic.getCompatibleDonors(bloodGroup);
    String safeCity = city.toLowerCase().trim().replaceAll(' ', '_');
    
    // Simplified targeting to ensure 100% delivery success
    // We send to everyone in the city, and the app/user filters by blood type visually
    final message = {
      "message": {
        "topic": "city_$safeCity", 
        "notification": {
          "title": "🆘 طلب دم طارئ ($bloodGroup)",
          "body": "نداء استغاثة لفصيلة $bloodGroup في مدينة $city. ساهم في الإنقاذ!"
        },
        "data": {
          "requestId": requestId,
          "type": "emergency",
          "bloodGroup": bloodGroup,
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    };

    await _sendV1Notification(message);

    _broadcastToCompatibleDonorsInFirestore(
      city: city,
      compatibleTypes: compatibleTypes,
      notification: AppNotification(
        id: '',
        titleAr: "طلب دم طارئ",
        titleEn: "Emergency Blood Request",
        bodyAr: "🆘 نداء عاجل! فصيلة $bloodGroup مطلوبة في $city.",
        bodyEn: "🆘 Urgent! $bloodGroup needed in $city.",
        timestamp: DateTime.now(),
        type: NotificationType.emergency,
        requestId: requestId,
      ),
    );
  }

  Future<void> sendDirectNotification({
    required String targetUid,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
    NotificationType type = NotificationType.general,
    String? requestId,
  }) async {
    debugPrint("🔍 [FCM-DEBUG] sendDirectNotification to UID: $targetUid");
    
    final userDoc = await _fs.collection('users').doc(targetUid).get();
    final fcmToken = userDoc.data()?['fcmToken'];

    if (fcmToken != null) {
      debugPrint("🔍 [FCM-DEBUG] FCM Token Found: ${fcmToken.substring(0, 10)}...");
      final message = {
        "message": {
          "token": fcmToken,
          "notification": {
            "title": titleEn,
            "body": bodyEn
          },
          "data": {
            "requestId": requestId ?? '',
            "type": type.name,
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          }
        }
      };
      await _sendV1Notification(message);
    } else {
      debugPrint("⚠️ [FCM-DEBUG] No FCM Token found for user $targetUid in Firestore.");
    }

    await _fs.collection('users').doc(targetUid).collection('notifications').add(AppNotification(
      id: '',
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr,
      bodyEn: bodyEn,
      timestamp: DateTime.now(),
      type: type,
      requestId: requestId,
    ).toMap());
  }

  Future<void> _sendV1Notification(Map<String, dynamic> message) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) return;

      final projectId = _serviceAccount['project_id'];
      debugPrint("🔍 [FCM-DEBUG] Sending Request to Projects V1 API...");
      
      final response = await http.post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/$projectId/messages:send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ [FCM-DEBUG] Push Sent Successfully: ${response.body}");
      } else {
        debugPrint("❌ [FCM-DEBUG] Push Failed (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ [FCM-DEBUG] Exception in _sendV1Notification: $e");
    }
  }

  Future<void> _broadcastToCompatibleDonorsInFirestore({
    required String city,
    required List<String> compatibleTypes,
    required AppNotification notification,
  }) async {
    final donorsSnapshot = await _fs
        .collection('users')
        .where('role', isEqualTo: 'donor')
        .where('city', isEqualTo: city)
        .where('bloodGroup', whereIn: compatibleTypes)
        .get();

    final batch = _fs.batch();
    for (var doc in donorsSnapshot.docs) {
      final ref = _fs.collection('users').doc(doc.id).collection('notifications').doc();
      batch.set(ref, notification.toMap());
    }
    await batch.commit();
  }

  Stream<int> getUnreadCountStream(String userId) {
    return _fs
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _fs.collection('users').doc(userId).collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _fs.batch();
    final unread = await _fs.collection('users').doc(userId).collection('notifications').where('isRead', isEqualTo: false).get();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> logout() async {}
}
