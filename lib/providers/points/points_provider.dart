import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sheryan/providers/auth/auth_provider.dart';

Map<String, dynamic> _docToMap(DocumentSnapshot d) {
  final data = d.data() as Map<String, dynamic>? ?? {};
  return <String, dynamic>{'id': d.id, ...data};
}

final pointsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value({'points': 0, 'tier': 'bronze'});

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((s) => <String, dynamic>{
            'points': (s.data()?['points'] as int?) ?? 0,
            'tier': (s.data()?['tier'] as String?) ?? 'bronze',
          });
});

final pointsHistoryProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('pointsHistory')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(_docToMap).toList());
});

final sponsorRewardsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, sponsorId) {
  return FirebaseFirestore.instance
      .collection('rewards')
      .where('sponsorId', isEqualTo: sponsorId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(_docToMap).toList());
});

final cityRewardsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, city) {
  Query q = FirebaseFirestore.instance
      .collection('rewards')
      .where('isActive', isEqualTo: true);
  if (city.isNotEmpty) {
    q = q.where('city', isEqualTo: city);
  }
  return q
      .orderBy('pointsRequired')
      .snapshots()
      .map((s) => s.docs.map(_docToMap).toList());
});

final sponsorRedemptionsCountProvider =
    StreamProvider.family<int, String>((ref, sponsorId) {
  return FirebaseFirestore.instance
      .collection('redemptions')
      .where('sponsorId', isEqualTo: sponsorId)
      .snapshots()
      .map((s) => s.docs.length);
});
