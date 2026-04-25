import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init(BuildContext context) async {
    // 1. Request permissions ( لبق )
    await _requestPermissions(context);

    // 2. Handle Token Refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(newToken);
    });

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showForegroundSnackBar(context, message);
    });

    // 4. Initial Token Save
    String? token = await _fcm.getToken();
    if (token != null) {
      _saveTokenToDatabase(token);
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    NotificationSettings settings = await _fcm.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      // Show custom dialog before system prompt (Best Practice)
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
          await _fcm.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showForegroundSnackBar(BuildContext context, RemoteMessage message) {
    if (message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.notification!.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(message.notification!.body ?? ''),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
