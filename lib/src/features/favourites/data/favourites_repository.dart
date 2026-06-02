import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sports_app/src/features/favourites/domain/favourite_entry.dart';

class FavouritesRepository {
  FavouritesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _teamsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favouriteTeams');

  CollectionReference<Map<String, dynamic>> _leaguesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favouriteLeagues');

  String _docId(String sport, String id) => '$sport:$id';

  Stream<List<FavouriteEntry>> teamsStream(String uid) =>
      _teamsRef(uid).orderBy('addedAt', descending: true).snapshots().map(
        (s) => s.docs
            .map((d) => FavouriteEntry.fromMap(d.id, d.data()))
            .toList(),
      );

  Stream<List<FavouriteEntry>> leaguesStream(String uid) =>
      _leaguesRef(uid).orderBy('addedAt', descending: true).snapshots().map(
        (s) => s.docs
            .map((d) => FavouriteEntry.fromMap(d.id, d.data()))
            .toList(),
      );

  Stream<bool> isTeamFavourited(String uid, String sport, String teamId) =>
      _teamsRef(uid)
          .doc(_docId(sport, teamId))
          .snapshots()
          .map((s) => s.exists);

  Stream<bool> isLeagueFavourited(String uid, String sport, String leagueId) =>
      _leaguesRef(uid)
          .doc(_docId(sport, leagueId))
          .snapshots()
          .map((s) => s.exists);

  Future<void> toggleTeam({
    required String uid,
    required String sport,
    required String teamId,
    required String name,
    String? cnName,
    String? logoUrl,
  }) async {
    final ref = _teamsRef(uid).doc(_docId(sport, teamId));
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'id': teamId,
        'sport': sport,
        'name': name,
        'cnName': cnName,
        'logoUrl': logoUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> toggleLeague({
    required String uid,
    required String sport,
    required String leagueId,
    required String name,
    String? cnName,
    String? logoUrl,
  }) async {
    final ref = _leaguesRef(uid).doc(_docId(sport, leagueId));
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'id': leagueId,
        'sport': sport,
        'name': name,
        'cnName': cnName,
        'logoUrl': logoUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
