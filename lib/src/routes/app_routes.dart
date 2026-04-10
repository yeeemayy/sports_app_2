abstract final class AppRoutes {
  // Shell branches
  static const home = '/home';
  static const event = '/event';
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

  // Anchor
  static const anchor = '/anchor/:anchorId';
  static String anchorPath(int id) => '/anchor/$id';

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
}