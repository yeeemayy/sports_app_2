import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shenghaotiyu/src/features/prediction/domain/prediction_model.dart';

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

  DocumentReference<Map<String, dynamic>> _pickRef(String uid, String matchId) =>
      _firestore.collection('users').doc(uid).collection('predictionPicks').doc(matchId);

  DocumentReference<Map<String, dynamic>> _statsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('predictionStats').doc('summary');

  Stream<PredictionStats> statsStream(String uid) => _statsRef(uid).snapshots().map(
    (s) => s.exists ? PredictionStats.fromMap(s.data()!) : const PredictionStats(),
  );

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
    required String nickname,
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
      tx.set(_pickRef(uid, matchId), {
        'pick': pickStr,
        'resolved': false,
        'correct': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // ponytail: nickname lives in the REST backend, not Firestore, so the
      // leaderboard can't join it in server-side — stash it here instead,
      // refreshed on every vote so renames eventually catch up.
      tx.set(_statsRef(uid), {'nickname': nickname}, SetOptions(merge: true));
    });
  }

  /// Awards points for a finished match if the user's pick hasn't been
  /// scored yet. Safe to call repeatedly — a no-op once resolved.
  Future<void> resolveIfNeeded({
    required String uid,
    required String matchId,
    required PredictionPick actualResult,
  }) async {
    final pickRef = _pickRef(uid, matchId);
    final statsRef = _statsRef(uid);

    await _firestore.runTransaction((tx) async {
      final pickSnap = await tx.get(pickRef);
      if (!pickSnap.exists || pickSnap.data()?['resolved'] == true) return;

      final pickStr = pickSnap.data()?['pick'] as String?;
      final pick = switch (pickStr) {
        'home' => PredictionPick.home,
        'draw' => PredictionPick.draw,
        'away' => PredictionPick.away,
        _ => null,
      };
      if (pick == null) return;

      final correct = pick == actualResult;
      final statsSnap = await tx.get(statsRef);
      final current = statsSnap.exists
          ? PredictionStats.fromMap(statsSnap.data()!)
          : const PredictionStats();
      final newStreak = correct ? current.streak + 1 : 0;
      final updated = PredictionStats(
        points: current.points + (correct ? 3 : 0),
        streak: newStreak,
        bestStreak: newStreak > current.bestStreak ? newStreak : current.bestStreak,
        correct: current.correct + (correct ? 1 : 0),
        total: current.total + 1,
      );

      tx.update(pickRef, {'resolved': true, 'correct': correct});
      tx.set(statsRef, updated.toMap());
    });
  }
}
