import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/core/services/api_service.dart';
import 'package:sports_app/src/features/league/domain/league_sport.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/basketball_team_stat.dart';
import 'package:sports_app/src/features/league/domain/models/country_league_item.dart';
import 'package:sports_app/src/features/league/domain/models/country_model.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_detail.dart';
import 'package:sports_app/src/features/league/domain/models/football_player_stat.dart';
import 'package:sports_app/src/features/league/domain/models/football_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/football_team_stat.dart';
import 'package:sports_app/src/features/league/domain/models/generic_standings_model.dart';
import 'package:sports_app/src/features/league/domain/models/league_detail_model.dart';
import 'package:sports_app/src/features/league/domain/models/amfootball_lineup_player.dart';
import 'package:sports_app/src/features/league/domain/models/league_item.dart';
import 'package:sports_app/src/features/league/domain/models/simple_team_detail.dart';
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

  // ─── Generic methods for Tennis, Cricket, Baseball, Volleyball,
  //     Badminton, Table Tennis, Ice Hockey, American Football ──────────────

  /// Fetches hot leagues for any sport using its [hotLeaguesListKey].
  Future<List<LeagueItem>> getHotLeagues(LeagueSport sport) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/${sport.apiPath}/league/list');
    final list = res.data[sport.hotLeaguesListKey] as List;
    return list
        .map((j) => LeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Returns categories or countries for the browse grid.
  /// Returns empty list if [sport.usesCategoryBrowse] is null (Tennis).
  Future<List<CountryModel>> getBrowseItems(LeagueSport sport) async {
    if (sport.usesCategoryBrowse == null) return [];
    final dio = _ref.read(sportsApiServiceProvider);

    if (sport.usesCategoryBrowse!) {
      // /category/list
      final res =
          await dio.get('/${sport.apiPath}/category/list');
      final List raw;
      if (sport == LeagueSport.badminton) {
        raw = res.data['categoryList'] as List;
      } else {
        // cricket, table_tennis, hockey, amfootball → wrapped in 'data'
        raw = res.data['data'] as List;
      }
      return raw
          .map((j) =>
              CountryModel.fromCategoryJson(j as Map<String, dynamic>))
          .toList();
    } else {
      // /country/list  (baseball, volleyball)
      final res =
          await dio.get('/${sport.apiPath}/country/list');
      final List raw = res.data['countryList'] as List;
      return raw
          .map((j) => CountryModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
  }

  /// Returns leagues under a given country or category id.
  Future<List<CountryLeagueItem>> getLeaguesByBrowseId(
      LeagueSport sport, String id) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final useCategory = sport.usesCategoryBrowse ?? false;
    final endpoint = useCategory
        ? '/${sport.apiPath}/category/leagues/$id'
        : '/${sport.apiPath}/country/leagues/$id';

    final res = await dio.get(endpoint);

    final List raw;
    if (sport == LeagueSport.badminton ||
        sport == LeagueSport.baseball ||
        sport == LeagueSport.volleyball) {
      // Returns array directly (no wrapper)
      raw = res.data as List;
    } else {
      // cricket, table_tennis, hockey, amfootball → wrapped in 'data'
      raw = res.data['data'] as List;
    }

    return raw
        .map((j) =>
            CountryLeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Fetches league detail for any new sport (all wrap in 'leagueDetails').
  Future<LeagueDetailModel> getGenericLeagueDetail(
      LeagueSport sport, String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/${sport.apiPath}/league/details/$leagueId');
    return LeagueDetailModel.fromJson(
        res.data['leagueDetails'] as Map<String, dynamic>);
  }

  /// Fetches standings for any new sport.  All use the same map format.
  Future<Map<String, GenericStandingsGroup>> getGenericStandings(
      LeagueSport sport, String leagueId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio
        .get('/${sport.apiPath}/league/season/standings/$leagueId');
    final map = res.data['standings'] as Map<String, dynamic>? ?? {};
    return map.map((key, value) => MapEntry(
          key,
          GenericStandingsGroup.fromJson(value as Map<String, dynamic>),
        ));
  }

  /// Fetches team / participant detail for any new sport.
  /// AmFootball wraps the object in a 'data' key.
  Future<SimpleTeamDetail> getGenericTeamDetail(
      LeagueSport sport, String teamId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/${sport.apiPath}/team/details/$teamId');
    final Map<String, dynamic> data;
    if (sport == LeagueSport.amFootball) {
      data = res.data['data'] as Map<String, dynamic>;
    } else {
      data = res.data as Map<String, dynamic>;
    }
    return SimpleTeamDetail.fromJson(data);
  }

  /// Fetches American Football team lineup/roster.
  Future<List<AmFootballLineupPlayer>> getAmFootballLineup(
      String teamId) async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res =
        await dio.get('/amfootball/team/lineup/details/$teamId');
    final list = res.data['data'] as List? ?? [];
    return list
        .map((j) =>
            AmFootballLineupPlayer.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the Tennis parent competition list for the "Other Leagues" section.
  Future<List<LeagueItem>> getTennisParentLeagues() async {
    final dio = _ref.read(sportsApiServiceProvider);
    final res = await dio.get('/tennis/competition/parent/list');
    final list = res.data['data'] as List? ?? [];
    return list.map((j) {
      final m = j as Map<String, dynamic>;
      return LeagueItem(
        id: (m['id'] as String?) ?? '',
        nameEn: (m['name'] as String?) ?? '',
        nameEnShort: null,
        nameCn: m['name_cn'] as String?,
        logo: (m['logo'] as String?) ?? '',
      );
    }).toList();
  }
}
