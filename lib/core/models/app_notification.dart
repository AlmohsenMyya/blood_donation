import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  emergency,
  verification,
  gratitude,
  general
}

class AppNotification {
  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final String? requestId;

  AppNotification({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.requestId,
  });

  Map<String, dynamic> toMap() {
    return {
      'titleAr': titleAr,
      'titleEn': titleEn,
      'bodyAr': bodyAr,
      'bodyEn': bodyEn,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
      'type': type.name,
      'requestId': requestId,
    };
  }

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      titleAr: map['titleAr'] ?? '',
      titleEn: map['titleEn'] ?? '',
      bodyAr: map['bodyAr'] ?? '',
      bodyEn: map['bodyEn'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
      requestId: map['requestId'],
    );
  }
}
