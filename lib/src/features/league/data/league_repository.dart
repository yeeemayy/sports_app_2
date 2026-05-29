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

  // ─── Private fetch helpers ─────────────────────────────────────────────────

  Future<List<T>> _getKeyedList<T>(
    String path,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final res = await _ref.read(sportsApiServiceProvider).get(path);
    return (res.data[key] as List)
        .map((j) => fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<T> _getKeyedObject<T>(
    String path,
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final res = await _ref.read(sportsApiServiceProvider).get(path);
    return fromJson(res.data[key] as Map<String, dynamic>);
  }

  Future<List<T>> _getRawList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final res = await _ref.read(sportsApiServiceProvider).get(path);
    return (res.data as List)
        .map((j) => fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ─── Football ──────────────────────────────────────────────────────────────

  Future<List<LeagueItem>> getFootballHotLeagues() => _getKeyedList(
    '/football/league/list',
    'footballHotLeaguesList',
    LeagueItem.fromJson,
  );

  Future<List<CountryModel>> getFootballCountries() => _getKeyedList(
    '/football/country/list',
    'countryList',
    CountryModel.fromJson,
  );

  Future<List<CountryLeagueItem>> getFootballLeaguesByCountry(
    String countryId,
  ) => _getRawList(
    '/football/country/leagues/$countryId',
    CountryLeagueItem.fromJson,
  );

  Future<LeagueDetailModel> getFootballLeagueDetail(String leagueId) =>
      _getKeyedObject(
        '/football/league/details/$leagueId',
        'leagueDetails',
        LeagueDetailModel.fromJson,
      );

  Future<List<FootballStandingsGroup>> getFootballStandings(String leagueId) =>
      _getKeyedList(
        '/football/league/season/standings/$leagueId',
        'standings',
        FootballStandingsGroup.fromJson,
      );

  Future<List<FootballPlayerStat>> getFootballPlayerStats(String leagueId) =>
      _getKeyedList(
        '/football/league/season/playersStats/$leagueId',
        'playersStats',
        FootballPlayerStat.fromJson,
      );

  Future<List<FootballTeamStat>> getFootballTeamStats(String leagueId) =>
      _getKeyedList(
        '/football/league/season/teamsStats/$leagueId',
        'teamsStats',
        FootballTeamStat.fromJson,
      );

  Future<TeamDetailModel> getFootballTeamDetail(String teamId) async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/football/team/details/$teamId');
    return TeamDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SquadPlayer>> getFootballSquad(String teamId) => _getKeyedList(
    '/football/team/squad/$teamId',
    'teamPlayers',
    SquadPlayer.fromJson,
  );

  Future<FootballPlayerDetail> getFootballPlayerDetail(String playerId) =>
      _getKeyedObject(
        '/football/player/details/$playerId',
        'playerDetails',
        FootballPlayerDetail.fromJson,
      );

  // ─── Basketball ────────────────────────────────────────────────────────────

  Future<List<LeagueItem>> getBasketballHotLeagues() => _getKeyedList(
    '/basketball/league/list',
    'basketballHotLeaguesList',
    LeagueItem.fromJson,
  );

  Future<List<CountryModel>> getBasketballCountries() => _getKeyedList(
    '/basketball/country/list',
    'countryList',
    CountryModel.fromJson,
  );

  Future<List<CountryLeagueItem>> getBasketballLeaguesByCountry(
    String countryId,
  ) => _getRawList(
    '/basketball/country/leagues/$countryId',
    CountryLeagueItem.fromJson,
  );

  Future<LeagueDetailModel> getBasketballLeagueDetail(String leagueId) =>
      _getKeyedObject(
        '/basketball/league/details/$leagueId',
        'leagueDetails',
        LeagueDetailModel.fromJson,
      );

  Future<Map<String, BasketballConferenceGroup>> getBasketballStandings(
    String leagueId,
  ) async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/basketball/league/season/standings/$leagueId');
    final map = res.data['standings'] as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(
        key,
        BasketballConferenceGroup.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<List<BasketballPlayerStat>> getBasketballPlayerStats(
    String leagueId,
  ) => _getKeyedList(
    '/basketball/league/season/playersStats/$leagueId',
    'playersStats',
    BasketballPlayerStat.fromJson,
  );

  Future<List<BasketballTeamStat>> getBasketballTeamStats(String leagueId) =>
      _getKeyedList(
        '/basketball/league/season/teamsStats/$leagueId',
        'teamsStats',
        BasketballTeamStat.fromJson,
      );

  Future<TeamDetailModel> getBasketballTeamDetail(String teamId) async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/basketball/team/details/$teamId');
    return TeamDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SquadPlayer>> getBasketballSquad(String teamId) => _getKeyedList(
    '/basketball/team/squad/$teamId',
    'teamPlayers',
    SquadPlayer.fromJson,
  );

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
      final res = await dio.get('/${sport.apiPath}/category/list');
      // badminton uses 'categoryList'; others wrap in 'data'
      final List raw = sport == LeagueSport.badminton
          ? res.data['categoryList'] as List
          : res.data['data'] as List;
      return raw
          .map((j) => CountryModel.fromCategoryJson(j as Map<String, dynamic>))
          .toList();
    } else {
      final res = await dio.get('/${sport.apiPath}/country/list');
      return (res.data['countryList'] as List)
          .map((j) => CountryModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
  }

  /// Returns leagues under a given country or category id.
  Future<List<CountryLeagueItem>> getLeaguesByBrowseId(
    LeagueSport sport,
    String id,
  ) async {
    final useCategory = sport.usesCategoryBrowse ?? false;
    final path = useCategory
        ? '/${sport.apiPath}/category/leagues/$id'
        : '/${sport.apiPath}/country/leagues/$id';
    final res = await _ref.read(sportsApiServiceProvider).get(path);

    // badminton, baseball, volleyball return a bare array; others wrap in 'data'
    final List raw =
        (sport == LeagueSport.badminton ||
            sport == LeagueSport.baseball ||
            sport == LeagueSport.volleyball)
        ? res.data as List
        : res.data['data'] as List;

    return raw
        .map((j) => CountryLeagueItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<LeagueDetailModel> getGenericLeagueDetail(
    LeagueSport sport,
    String leagueId,
  ) => _getKeyedObject(
    '/${sport.apiPath}/league/details/$leagueId',
    'leagueDetails',
    LeagueDetailModel.fromJson,
  );

  Future<Map<String, GenericStandingsGroup>> getGenericStandings(
    LeagueSport sport,
    String leagueId,
  ) async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/${sport.apiPath}/league/season/standings/$leagueId');
    final map = res.data['standings'] as Map<String, dynamic>? ?? {};
    return map.map(
      (key, value) => MapEntry(
        key,
        GenericStandingsGroup.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  /// AmFootball wraps the team object in a 'data' key; all others return it directly.
  Future<SimpleTeamDetail> getGenericTeamDetail(
    LeagueSport sport,
    String teamId,
  ) async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/${sport.apiPath}/team/details/$teamId');
    final data = sport == LeagueSport.amFootball
        ? res.data['data'] as Map<String, dynamic>
        : res.data as Map<String, dynamic>;
    return SimpleTeamDetail.fromJson(data);
  }

  Future<List<AmFootballLineupPlayer>> getAmFootballLineup(
    String teamId,
  ) async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/amfootball/team/lineup/details/$teamId');
    return ((res.data['data'] as List?) ?? [])
        .map((j) => AmFootballLineupPlayer.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeagueItem>> getTennisParentLeagues() async {
    final res = await _ref
        .read(sportsApiServiceProvider)
        .get('/tennis/competition/parent/list');
    return ((res.data['data'] as List?) ?? []).map((j) {
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
