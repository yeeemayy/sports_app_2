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

  // Anchor
  static const anchor = '/anchor/:anchorId';
  static String anchorPath(int id) => '/anchor/$id';

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
}