import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/features/league/data/league_repository.dart';
import 'package:shenghaotiyu/src/features/league/domain/league_sport.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/basketball_standings_model.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/basketball_team_stat.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/country_league_item.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/country_model.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/football_player_detail.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/football_player_stat.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/football_standings_model.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/football_team_stat.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/generic_standings_model.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/amfootball_lineup_player.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/league_detail_model.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/league_item.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/simple_team_detail.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/squad_player.dart';
import 'package:shenghaotiyu/src/features/league/domain/models/team_detail_model.dart';

part 'league_providers.g.dart';

// ─── Football ──────────────────────────────────────────────────────────────

@riverpod
Future<List<LeagueItem>> footballHotLeagues(FootballHotLeaguesRef ref) =>
    ref.read(leagueRepositoryProvider).getFootballHotLeagues();

@riverpod
Future<List<CountryModel>> footballCountries(FootballCountriesRef ref) =>
    ref.read(leagueRepositoryProvider).getFootballCountries();

@riverpod
Future<List<CountryLeagueItem>> footballLeaguesByCountry(
  FootballLeaguesByCountryRef ref, {
  required String countryId,
}) => ref.read(leagueRepositoryProvider).getFootballLeaguesByCountry(countryId);

@riverpod
Future<LeagueDetailModel> footballLeagueDetail(
  FootballLeagueDetailRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getFootballLeagueDetail(leagueId);

@riverpod
Future<List<FootballStandingsGroup>> footballStandings(
  FootballStandingsRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getFootballStandings(leagueId);

@riverpod
Future<List<FootballPlayerStat>> footballPlayerStats(
  FootballPlayerStatsRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getFootballPlayerStats(leagueId);

@riverpod
Future<List<FootballTeamStat>> footballTeamStats(
  FootballTeamStatsRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getFootballTeamStats(leagueId);

@riverpod
Future<TeamDetailModel> footballTeamDetail(
  FootballTeamDetailRef ref, {
  required String teamId,
}) => ref.read(leagueRepositoryProvider).getFootballTeamDetail(teamId);

@riverpod
Future<List<SquadPlayer>> footballSquad(
  FootballSquadRef ref, {
  required String teamId,
}) => ref.read(leagueRepositoryProvider).getFootballSquad(teamId);

@riverpod
Future<FootballPlayerDetail> footballPlayerDetail(
  FootballPlayerDetailRef ref, {
  required String playerId,
}) => ref.read(leagueRepositoryProvider).getFootballPlayerDetail(playerId);

// ─── Basketball ────────────────────────────────────────────────────────────

@riverpod
Future<List<LeagueItem>> basketballHotLeagues(BasketballHotLeaguesRef ref) =>
    ref.read(leagueRepositoryProvider).getBasketballHotLeagues();

@riverpod
Future<List<CountryModel>> basketballCountries(BasketballCountriesRef ref) =>
    ref.read(leagueRepositoryProvider).getBasketballCountries();

@riverpod
Future<List<CountryLeagueItem>> basketballLeaguesByCountry(
  BasketballLeaguesByCountryRef ref, {
  required String countryId,
}) =>
    ref.read(leagueRepositoryProvider).getBasketballLeaguesByCountry(countryId);

@riverpod
Future<LeagueDetailModel> basketballLeagueDetail(
  BasketballLeagueDetailRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getBasketballLeagueDetail(leagueId);

@riverpod
Future<Map<String, BasketballConferenceGroup>> basketballStandings(
  BasketballStandingsRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getBasketballStandings(leagueId);

@riverpod
Future<List<BasketballPlayerStat>> basketballPlayerStats(
  BasketballPlayerStatsRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getBasketballPlayerStats(leagueId);

@riverpod
Future<List<BasketballTeamStat>> basketballTeamStats(
  BasketballTeamStatsRef ref, {
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getBasketballTeamStats(leagueId);

@riverpod
Future<TeamDetailModel> basketballTeamDetail(
  BasketballTeamDetailRef ref, {
  required String teamId,
}) => ref.read(leagueRepositoryProvider).getBasketballTeamDetail(teamId);

@riverpod
Future<List<SquadPlayer>> basketballSquad(
  BasketballSquadRef ref, {
  required String teamId,
}) => ref.read(leagueRepositoryProvider).getBasketballSquad(teamId);

// ─── Generic (Tennis, Cricket, Baseball, Volleyball, Badminton,
//     Table Tennis, Ice Hockey, American Football) ────────────────────────

@riverpod
Future<List<LeagueItem>> sportHotLeagues(
  SportHotLeaguesRef ref, {
  required LeagueSport sport,
}) => ref.read(leagueRepositoryProvider).getHotLeagues(sport);

@riverpod
Future<List<CountryModel>> sportBrowseItems(
  SportBrowseItemsRef ref, {
  required LeagueSport sport,
}) => ref.read(leagueRepositoryProvider).getBrowseItems(sport);

@riverpod
Future<List<CountryLeagueItem>> sportLeaguesByBrowseId(
  SportLeaguesByBrowseIdRef ref, {
  required LeagueSport sport,
  required String id,
}) => ref.read(leagueRepositoryProvider).getLeaguesByBrowseId(sport, id);

@riverpod
Future<LeagueDetailModel> sportLeagueDetail(
  SportLeagueDetailRef ref, {
  required LeagueSport sport,
  required String leagueId,
}) =>
    ref.read(leagueRepositoryProvider).getGenericLeagueDetail(sport, leagueId);

@riverpod
Future<Map<String, StandingsGroup>> leagueStandings(
  LeagueStandingsRef ref, {
  required LeagueSport sport,
  required String leagueId,
}) => ref.read(leagueRepositoryProvider).getLeagueStandings(sport, leagueId);

@riverpod
Future<SimpleTeamDetail> sportTeamDetail(
  SportTeamDetailRef ref, {
  required LeagueSport sport,
  required String teamId,
}) => ref.read(leagueRepositoryProvider).getSportTeamDetail(sport, teamId);

@riverpod
Future<List<AmFootballLineupPlayer>> amFootballLineup(
  AmFootballLineupRef ref, {
  required String teamId,
}) => ref.read(leagueRepositoryProvider).getAmFootballLineup(teamId);

@riverpod
Future<List<LeagueItem>> tennisParentLeagues(TennisParentLeaguesRef ref) =>
    ref.read(leagueRepositoryProvider).getTennisParentLeagues();
