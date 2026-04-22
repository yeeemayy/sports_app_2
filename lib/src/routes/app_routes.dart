abstract final class AppRoutes {
  // Shell branches
  static const home = '/home';
  static const anchor = '/anchor';
  static const news = '/news';
  static const data = '/data';
  static const profile = '/profile';

  // Profile sub-routes (relative)
  static const profileEdit = 'edit';
  static const profileEditFull = '/profile/edit';

  // Football match detail
  static const footballMatchDetail = '/event/football/:matchId';
  static String footballMatchDetailPath(String matchId) => '/event/football/$matchId';

  // Basketball match detail
  static const basketballMatchDetail = '/event/basketball/:matchId';
  static String basketballMatchDetailPath(String matchId) => '/event/basketball/$matchId';

  // Tennis match detail
  static const tennisMatchDetail = '/event/tennis/:matchId';
  static String tennisMatchDetailPath(String matchId) => '/event/tennis/$matchId';

  // Badminton match detail
  static const badmintonMatchDetail = '/event/badminton/:matchId';
  static String badmintonMatchDetailPath(String matchId) => '/event/badminton/$matchId';

  // Table tennis match detail
  static const tableTennisMatchDetail = '/event/table-tennis/:matchId';
  static String tableTennisMatchDetailPath(String matchId) => '/event/table-tennis/$matchId';

  // Baseball match detail
  static const baseballMatchDetail = '/event/baseball/:matchId';
  static String baseballMatchDetailPath(String matchId) => '/event/baseball/$matchId';

  // Volleyball match detail
  static const volleyballMatchDetail = '/event/volleyball/:matchId';
  static String volleyballMatchDetailPath(String matchId) => '/event/volleyball/$matchId';

  // Ice Hockey match detail
  static const iceHockeyMatchDetail = '/event/ice-hockey/:matchId';
  static String iceHockeyMatchDetailPath(String matchId) => '/event/ice-hockey/$matchId';

  // American Football match detail
  static const amFootballMatchDetail = '/event/am-football/:matchId';
  static String amFootballMatchDetailPath(String matchId) => '/event/am-football/$matchId';

  // Cricket match detail
  static const cricketMatchDetail = '/event/cricket/:matchId';
  static String cricketMatchDetailPath(String matchId) => '/event/cricket/$matchId';

  // News detail
  static const newsDetail = '/news/detail/:newsId';
  static String newsDetailPath(int id) => '/news/detail/$id';

  // Anchor
  static const anchorList = '/anchor/anchor-list';
  static const anchorDetail = '/anchor/anchor-list/:anchorId';
  static String anchorPath(int id) => '/anchor/anchor-list/$id';

  // Video highlight detail
  static const videoDetail = '/video/:videoId';
  static String videoDetailPath(int id, {int currentPage = 1, int lastPage = 1}) =>
      '/video/$id?page=$currentPage&lastPage=$lastPage';

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
}
