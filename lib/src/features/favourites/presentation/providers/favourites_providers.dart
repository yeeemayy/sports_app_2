export 'package:sports_app/src/features/prediction/presentation/providers/prediction_providers.dart'
    show firebaseUidProvider;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/favourites/data/favourites_repository.dart';
import 'package:sports_app/src/features/favourites/domain/favourite_entry.dart';

final favouritesRepositoryProvider = Provider<FavouritesRepository>(
  (ref) => FavouritesRepository(FirebaseFirestore.instance),
);

final favouriteTeamsProvider =
    StreamProvider.family<List<FavouriteEntry>, String>(
      (ref, uid) => ref.watch(favouritesRepositoryProvider).teamsStream(uid),
    );

final favouriteLeaguesProvider =
    StreamProvider.family<List<FavouriteEntry>, String>(
      (ref, uid) => ref.watch(favouritesRepositoryProvider).leaguesStream(uid),
    );

final isTeamFavouritedProvider = StreamProvider.family<
    bool,
    ({String uid, String sport, String teamId})>(
  (ref, args) => ref
      .watch(favouritesRepositoryProvider)
      .isTeamFavourited(args.uid, args.sport, args.teamId),
);

final isLeagueFavouritedProvider = StreamProvider.family<
    bool,
    ({String uid, String sport, String leagueId})>(
  (ref, args) => ref
      .watch(favouritesRepositoryProvider)
      .isLeagueFavourited(args.uid, args.sport, args.leagueId),
);
