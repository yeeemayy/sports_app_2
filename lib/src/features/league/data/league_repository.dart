import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_team_stat.dart';
import 'package:sports_app/src/features/league/domain/models/country_league_item.dart';
import 'package:sports_app/src/features/league/domain/models/country_model.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_detail.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/football_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/football_team_stat.dart';
import 'package:sports_app/src/features/league/domain/models/league_detail_model.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/domain/models/squad_player.dart';
import 'package:sports_app/src/features/league/domain/models/team_detail_model.dart';

part 'league_repository.g.dart';

@Riverpod(keepAlive: true)
LeagueRepository leagueRepository(LeagueRepositoryRef ref) {
  return LeagueRepository(ref);
}

class LeagueRepository {
  LeagueRepository(this._ref);
  final LeagueRepositoryRef _ref;

  // ─── Football ──────────────────────────────────────────────────────────────

  Future<List<LeagueItem>> getFootballHotLeagues() async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/football/league/list');
    final list = res.data['footballHotLeaguesList'] as List;
    return list
        .map((j) => LeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<CountryModel>> getFootballCountries() async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/football/country/list');
    final list = res.data['countryList'] as List;
    return list
        .map((j) => CountryModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<CountryLeagueItem>> getFootballLeaguesByCountry(
      String countryId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/football/country/leagues/$countryId');
    final list = res.data as List;
    return list
        .map((j) => CountryLeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<LeagueDetailModel> getFootballLeagueDetail(String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/football/league/details/$leagueId');
    return LeagueDetailModel.fromJson(
        res.data['leagueDetails'] as Map<String, dynamic>);
  }

  Future<List<FootballStandingsGroup>> getFootballStandings(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/football/league/season/standings/$leagueId');
    final list = res.data['standings'] as List;
    return list
        .map((j) =>
            FootballStandingsGroup.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<FootballPlayerStat>> getFootballPlayerStats(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/football/league/season/playersStats/$leagueId');
    final list = res.data['playersStats'] as List;
    return list
        .map((j) => FootballPlayerStat.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<FootballTeamStat>> getFootballTeamStats(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/football/league/season/teamsStats/$leagueId');
    final list = res.data['teamsStats'] as List;
    return list
        .map((j) => FootballTeamStat.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<TeamDetailModel> getFootballTeamDetail(String teamId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/football/team/details/$teamId');
    return TeamDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SquadPlayer>> getFootballSquad(String teamId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/football/team/squad/$teamId');
    final list = res.data['teamPlayers'] as List;
    return list
        .map((j) => SquadPlayer.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<FootballPlayerDetail> getFootballPlayerDetail(
      String playerId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/football/player/details/$playerId');
    return FootballPlayerDetail.fromJson(
        res.data['playerDetails'] as Map<String, dynamic>);
  }

  // ─── Basketball ────────────────────────────────────────────────────────────

  Future<List<LeagueItem>> getBasketballHotLeagues() async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/basketball/league/list');
    final list = res.data['basketballHotLeaguesList'] as List;
    return list
        .map((j) => LeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<CountryModel>> getBasketballCountries() async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/basketball/country/list');
    final list = res.data['countryList'] as List;
    return list
        .map((j) => CountryModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<CountryLeagueItem>> getBasketballLeaguesByCountry(
      String countryId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/basketball/country/leagues/$countryId');
    final list = res.data as List;
    return list
        .map((j) => CountryLeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<LeagueDetailModel> getBasketballLeagueDetail(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/basketball/league/details/$leagueId');
    final data = res.data['leagueDetails'] as Map<String, dynamic>;
    return LeagueDetailModel.fromJson(data);
  }

  Future<Map<String, BasketballConferenceGroup>> getBasketballStandings(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/basketball/league/season/standings/$leagueId');
    final map = res.data['standings'] as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(
          key,
          BasketballConferenceGroup.fromJson(value as Map<String, dynamic>),
        ));
  }

  Future<List<BasketballPlayerStat>> getBasketballPlayerStats(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/basketball/league/season/playersStats/$leagueId');
    final list = res.data['playersStats'] as List;
    return list
        .map((j) =>
            BasketballPlayerStat.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<BasketballTeamStat>> getBasketballTeamStats(
      String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/basketball/league/season/teamsStats/$leagueId');
    final list = res.data['teamsStats'] as List;
    return list
        .map((j) =>
            BasketballTeamStat.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<TeamDetailModel> getBasketballTeamDetail(String teamId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/basketball/team/details/$teamId');
    return TeamDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SquadPlayer>> getBasketballSquad(String teamId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/basketball/team/squad/$teamId');
    final list = res.data['teamPlayers'] as List;
    return list
        .map((j) => SquadPlayer.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
