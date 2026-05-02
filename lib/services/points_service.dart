import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointsEvent {
  static const String accountCreated = 'account_created';
  static const String basicInfoComplete = 'basic_info_complete';
  static const String healthInfoComplete = 'health_info_complete';
  static const String medicalHistoryComplete = 'medical_history_complete';
  static const String emergencyContactComplete = 'emergency_contact_complete';
  static const String bloodGroupVerified = 'blood_group_verified';
  static const String profileComplete = 'profile_100_bonus';
  static const String donationRegistered = 'donation_registered';
  static const String consecutiveDonation = 'consecutive_donation_bonus';
}

class PointsValue {
  static const int accountCreated = 20;
  static const int basicInfoComplete = 30;
  static const int healthInfoComplete = 30;
  static const int medicalHistoryComplete = 20;
  static const int emergencyContactComplete = 20;
  static const int bloodGroupVerified = 100;
  static const int profileComplete = 50;
  static const int donationRegistered = 200;
  static const int consecutiveDonation = 50;
}

class PointsService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  String tierForPoints(int points) {
    if (points >= 2000) return 'platinum';
    if (points >= 1000) return 'gold';
    if (points >= 500) return 'silver';
    return 'bronze';
  }

  Future<int> getPoints(String uid) async {
    final doc = await _fs.collection('users').doc(uid).get();
    return (doc.data()?['points'] as int?) ?? 0;
  }

  Future<void> awardPoints({
    required String uid,
    required String event,
    required int points,
    required String descriptionAr,
    required String descriptionEn,
  }) async {
    final userRef = _fs.collection('users').doc(uid);
    final historyRef = userRef.collection('pointsHistory').doc();

    await _fs.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final current = (snap.data()?['points'] as int?) ?? 0;
      final newTotal = current + points;
      final tier = tierForPoints(newTotal);

      tx.update(userRef, {
        'points': newTotal,
        'tier': tier,
      });

      tx.set(historyRef, {
        'event': event,
        'points': points,
        'descriptionAr': descriptionAr,
        'descriptionEn': descriptionEn,
        'total': newTotal,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<bool> hasEarnedEvent(String uid, String event) async {
    final snap = await _fs
        .collection('users')
        .doc(uid)
        .collection('pointsHistory')
        .where('event', isEqualTo: event)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> checkAndAwardProfileMilestones(
      String uid, Map<String, dynamic> profile) async {
    final bool basic = _basicComplete(profile);
    final bool health = _healthComplete(profile);
    final bool medical = _medicalComplete(profile);
    final bool emergency = _emergencyComplete(profile);
    final bool verified = profile['bloodGroupVerified'] == true;

    if (basic && !await hasEarnedEvent(uid, PointsEvent.basicInfoComplete)) {
      await awardPoints(
        uid: uid,
        event: PointsEvent.basicInfoComplete,
        points: PointsValue.basicInfoComplete,
        descriptionAr: 'اكتمال المعلومات الأساسية',
        descriptionEn: 'Basic info completed',
      );
    }
    if (health && !await hasEarnedEvent(uid, PointsEvent.healthInfoComplete)) {
      await awardPoints(
        uid: uid,
        event: PointsEvent.healthInfoComplete,
        points: PointsValue.healthInfoComplete,
        descriptionAr: 'اكتمال البيانات الصحية',
        descriptionEn: 'Health info completed',
      );
    }
    if (medical &&
        !await hasEarnedEvent(uid, PointsEvent.medicalHistoryComplete)) {
      await awardPoints(
        uid: uid,
        event: PointsEvent.medicalHistoryComplete,
        points: PointsValue.medicalHistoryComplete,
        descriptionAr: 'اكتمال السجل الطبي',
        descriptionEn: 'Medical history completed',
      );
    }
    if (emergency &&
        !await hasEarnedEvent(uid, PointsEvent.emergencyContactComplete)) {
      await awardPoints(
        uid: uid,
        event: PointsEvent.emergencyContactComplete,
        points: PointsValue.emergencyContactComplete,
        descriptionAr: 'اكتمال جهة الاتصال الطارئة',
        descriptionEn: 'Emergency contact completed',
      );
    }
    if (verified &&
        !await hasEarnedEvent(uid, PointsEvent.bloodGroupVerified)) {
      await awardPoints(
        uid: uid,
        event: PointsEvent.bloodGroupVerified,
        points: PointsValue.bloodGroupVerified,
        descriptionAr: 'توثيق زمرة الدم',
        descriptionEn: 'Blood group verified',
      );
    }
    if (basic &&
        health &&
        medical &&
        emergency &&
        verified &&
        !await hasEarnedEvent(uid, PointsEvent.profileComplete)) {
      await awardPoints(
        uid: uid,
        event: PointsEvent.profileComplete,
        points: PointsValue.profileComplete,
        descriptionAr: 'مكافأة إكمال الملف 100%',
        descriptionEn: '100% profile completion bonus',
      );
    }
  }

  Future<void> awardDonationPoints(String uid, String hospitalName) async {
    await awardPoints(
      uid: uid,
      event: PointsEvent.donationRegistered,
      points: PointsValue.donationRegistered,
      descriptionAr: 'تبرع موثق - $hospitalName',
      descriptionEn: 'Verified donation - $hospitalName',
    );
  }

  Future<bool> deductPoints({
    required String donorUid,
    required String sponsorUid,
    required String rewardId,
    required String rewardTitle,
    required int pointsRequired,
  }) async {
    final userRef = _fs.collection('users').doc(donorUid);
    final redemptionRef = _fs.collection('redemptions').doc();

    bool success = false;
    await _fs.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final current = (snap.data()?['points'] as int?) ?? 0;
      if (current < pointsRequired) {
        success = false;
        return;
      }
      final newTotal = current - pointsRequired;
      final tier = tierForPoints(newTotal);

      tx.update(userRef, {'points': newTotal, 'tier': tier});
      tx.set(redemptionRef, {
        'donorId': donorUid,
        'sponsorId': sponsorUid,
        'rewardId': rewardId,
        'rewardTitle': rewardTitle,
        'pointsDeducted': pointsRequired,
        'redeemedAt': FieldValue.serverTimestamp(),
      });
      success = true;
    });
    return success;
  }

  bool _basicComplete(Map<String, dynamic> d) =>
      _f(d['name']) && _f(d['phone']) && _f(d['city']) && _f(d['bloodGroup']);

  bool _healthComplete(Map<String, dynamic> d) =>
      d['height'] != null &&
      d['weight'] != null &&
      _f(d['gender']) &&
      _f(d['smokingStatus']);

  bool _medicalComplete(Map<String, dynamic> d) => _f(d['lastDonated']);

  bool _emergencyComplete(Map<String, dynamic> d) =>
      _f(d['emergencyContactName']) && _f(d['emergencyContactPhone']);

  bool _f(dynamic v) => v != null && v.toString().trim().isNotEmpty;
}
