import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheryan/core/models/app_notification.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';
import 'package:sheryan/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            tooltip: "Mark all as read",
            icon: const Icon(Icons.done_all),
            onPressed: () => NotificationService().markAllAsRead(userId),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(l10n.noNotificationsFound, style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return _NotificationItem(notification: item, userId: userId);
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final String userId;

  const _NotificationItem({required this.notification, required this.userId});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'ar' ? notification.titleAr : notification.titleEn;
    final body = locale == 'ar' ? notification.bodyAr : notification.bodyEn;
    final timeStr = DateFormat('hh:mm a, dd MMM').format(notification.timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.transparent : AppColors.primaryRed.withOpacity(0.05),
        borderRadius: AppDesignConstants.borderRadiusMedium,
        border: Border.all(
          color: notification.isRead ? Colors.grey.shade800 : AppColors.primaryRed.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.type).withOpacity(0.2),
          child: Icon(_getTypeIcon(notification.type), color: _getTypeColor(notification.type), size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 4),
            Text(timeStr, style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ],
        ),
        onTap: () {
          NotificationService().markAsRead(userId, notification.id);
        },
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.emergency: return Icons.warning_amber_rounded;
      case NotificationType.verification: return Icons.verified_user_rounded;
      case NotificationType.gratitude: return Icons.favorite_rounded;
      default: return Icons.notifications;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.emergency: return AppColors.error;
      case NotificationType.verification: return Colors.blue;
      case NotificationType.gratitude: return AppColors.success;
      default: return AppColors.primaryRed;
    }
  }
}
