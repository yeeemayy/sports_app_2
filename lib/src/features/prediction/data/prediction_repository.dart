import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_app/src/features/prediction/domain/prediction_model.dart';

class PredictionRepository {
  PredictionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _tallyRef(String matchId) =>
      _firestore.collection('predictions').doc(matchId);

  DocumentReference<Map<String, dynamic>> _userVoteRef(
    String matchId,
    String uid,
  ) => _firestore
      .collection('predictions')
      .doc(matchId)
      .collection('userVotes')
      .doc(uid);

  Stream<PredictionTally> tallyStream(String matchId) =>
      _tallyRef(matchId).snapshots().map(
        (s) => s.exists
            ? PredictionTally.fromMap(s.data()!)
            : const PredictionTally(),
      );

  Stream<PredictionPick?> userVoteStream(String matchId, String uid) =>
      _userVoteRef(matchId, uid).snapshots().map((s) {
        if (!s.exists) return null;
        final raw = s.data()?['pick'] as String?;
        return switch (raw) {
          'home' => PredictionPick.home,
          'draw' => PredictionPick.draw,
          'away' => PredictionPick.away,
          _ => null,
        };
      });

  Future<void> vote({
    required String matchId,
    required String uid,
    required PredictionPick pick,
  }) async {
    final pickStr = pick.name; // 'home' | 'draw' | 'away'
    final tallyRef = _tallyRef(matchId);
    final userRef = _userVoteRef(matchId, uid);

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final tallySnap = await tx.get(tallyRef);

      final prevRaw = userSnap.exists
          ? (userSnap.data()?['pick'] as String?)
          : null;
      if (prevRaw != null) return; // already voted — one vote per user

      final Map<String, dynamic> tallyUpdates = {
        '${pickStr}Votes': FieldValue.increment(1),
      };

      if (tallySnap.exists) {
        tx.update(tallyRef, tallyUpdates);
      } else {
        final base = const PredictionTally().toMap();
        base['${pickStr}Votes'] = 1;
        tx.set(tallyRef, base);
      }

      tx.set(userRef, {'pick': pickStr});
    });
  }
}
