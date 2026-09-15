import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/features/prediction/data/leaderboard_repository.dart';
import 'package:shenghaotiyu/src/features/prediction/domain/leaderboard_entry.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepository(FirebaseFirestore.instance),
);

final leaderboardTopProvider =
    StreamProvider.family<List<LeaderboardEntry>, ({int limit, String sortBy})>(
      (ref, args) => ref
          .watch(leaderboardRepositoryProvider)
          .topStream(args.limit, orderBy: args.sortBy),
    );
