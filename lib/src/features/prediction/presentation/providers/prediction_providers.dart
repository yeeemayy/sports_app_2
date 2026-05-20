import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/features/prediction/data/prediction_repository.dart';
import 'package:sports_app/src/features/prediction/domain/prediction_model.dart';

final firebaseUidProvider = Provider<String?>(
  (ref) => FirebaseAuth.instance.currentUser?.uid,
);

final predictionRepositoryProvider = Provider<PredictionRepository>(
  (ref) => PredictionRepository(FirebaseFirestore.instance),
);

final predictionTallyProvider = StreamProvider.family<PredictionTally, String>(
  (ref, matchId) =>
      ref.watch(predictionRepositoryProvider).tallyStream(matchId),
);

final userVoteProvider =
    StreamProvider.family<PredictionPick?, ({String matchId, String uid})>(
  (ref, args) => ref
      .watch(predictionRepositoryProvider)
      .userVoteStream(args.matchId, args.uid),
);
