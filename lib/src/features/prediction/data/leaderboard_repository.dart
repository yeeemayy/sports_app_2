import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shenghaotiyu/src/features/prediction/domain/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<LeaderboardEntry>> topStream(
    int limit, {
    String orderBy = 'points',
  }) {
    return _firestore
        .collection('leaderboard')
        .orderBy(orderBy, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => LeaderboardEntry.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
