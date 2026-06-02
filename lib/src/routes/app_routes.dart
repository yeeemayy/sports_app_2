abstract final class AppRoutes {
  // Shell branches
  static const home = '/home';
  static const anchor = '/anchor';
  static const news = '/news';
  static const data = '/data';
  static const league = '/league';
  static const profile = '/profile';

  // League sub-routes (pushed outside shell)
  static const leagueCountry = '/league/country/:sport/:countryId';
  static const leagueDetail = '/league/detail/:sport/:leagueId';
  static const leagueTeam = '/league/team/:sport/:teamId';
  static const leaguePlayer = '/league/player/:sport/:playerId';
  static const leagueHotBrowse = '/league/hot';
  static const leagueSearch = '/league/search';

  static String leagueCountryPath(String sport, String countryId) =>
      '/league/country/$sport/$countryId';
  static String leagueDetailPath(String sport, String leagueId) =>
      '/league/detail/$sport/$leagueId';
  static String leagueTeamPath(String sport, String teamId) =>
      '/league/team/$sport/$teamId';
  static String leaguePlayerPath(String sport, String playerId) =>
      '/league/player/$sport/$playerId';

  // Profile sub-routes (relative)
  static const profileEdit = 'edit';
  static const profileEditFull = '/profile/edit';
  static const profileFavourites = '/profile/favourites';
  static const privacyPolicy = '/profile/privacy-policy';
  static const userAgreement = '/profile/user-agreement';

  // Football match detail
  static const footballMatchDetail = '/event/football/:matchId';
  static String footballMatchDetailPath(String matchId) =>
      '/event/football/$matchId';

  // Basketball match detail
  static const basketballMatchDetail = '/event/basketball/:matchId';
  static String basketballMatchDetailPath(String matchId) =>
      '/event/basketball/$matchId';

  // Tennis match detail
  static const tennisMatchDetail = '/event/tennis/:matchId';
  static String tennisMatchDetailPath(String matchId) =>
      '/event/tennis/$matchId';

  // Badminton match detail
  static const badmintonMatchDetail = '/event/badminton/:matchId';
  static String badmintonMatchDetailPath(String matchId) =>
      '/event/badminton/$matchId';

  // Table tennis match detail
  static const tableTennisMatchDetail = '/event/table-tennis/:matchId';
  static String tableTennisMatchDetailPath(String matchId) =>
      '/event/table-tennis/$matchId';

  // Baseball match detail
  static const baseballMatchDetail = '/event/baseball/:matchId';
  static String baseballMatchDetailPath(String matchId) =>
      '/event/baseball/$matchId';

  // Volleyball match detail
  static const volleyballMatchDetail = '/event/volleyball/:matchId';
  static String volleyballMatchDetailPath(String matchId) =>
      '/event/volleyball/$matchId';

  // Ice Hockey match detail
  static const iceHockeyMatchDetail = '/event/ice-hockey/:matchId';
  static String iceHockeyMatchDetailPath(String matchId) =>
      '/event/ice-hockey/$matchId';

  // American Football match detail
  static const amFootballMatchDetail = '/event/am-football/:matchId';
  static String amFootballMatchDetailPath(String matchId) =>
      '/event/am-football/$matchId';

  // Cricket match detail
  static const cricketMatchDetail = '/event/cricket/:matchId';
  static String cricketMatchDetailPath(String matchId) =>
      '/event/cricket/$matchId';

  // News detail
  static const newsDetail = '/news/detail/:newsId';
  static String newsDetailPath(int id) => '/news/detail/$id';

  // News category list (intermediary "more" screen)
  static const newsCategoryList = '/news/category';

  // Anchor
  static const anchorList = '/anchor/anchor-list';
  static const anchorDetail = '/anchor/anchor-list/:anchorId';
  static String anchorPath(int id) => '/anchor/anchor-list/$id';

  // Video highlight detail
  static const videoDetail = '/video/:videoId';
  static String videoDetailPath(
    int id, {
    int currentPage = 1,
    int lastPage = 1,
  }) => '/video/$id?page=$currentPage&lastPage=$lastPage';

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
}
