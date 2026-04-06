import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/event/data/event_repository.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

part 'event_providers.g.dart';

@riverpod
Future<List<SportMatch>> sportHotMatches(
  SportHotMatchesRef ref, {
  required SportType sport,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getHotLeagueMatches(sport: sport);
}

@riverpod
Future<List<SportMatch>> sportMatches(
  SportMatchesRef ref, {
  required SportType sport,
  String matchStatus = 'all',
}) {
  return ref.watch(eventRepositoryProvider.notifier).getMatches(
        sport: sport,
        matchStatus: matchStatus,
      );
}

@riverpod
Future<List<SportMatch>> footballScheduledMatches(
  FootballScheduledMatchesRef ref, {
  required String date,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getScheduledMatches(date: date);
}

@riverpod
Future<FootballMatchDetail> footballMatchDetail(
  FootballMatchDetailRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getFootballMatchDetail(matchId);
}

@riverpod
Future<FootballLineups?> footballMatchLineups(
  FootballMatchLineupsRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getFootballMatchLineups(matchId);
}

@riverpod
Future<FootballMatchEvents> footballMatchEventsKey(
  FootballMatchEventsKeyRef ref, {
  required String matchId,
}) {
  return ref.watch(eventRepositoryProvider.notifier).getFootballMatchEventsKey(matchId);
}
