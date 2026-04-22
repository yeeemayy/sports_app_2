import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  AppInfo._();

  static late final PackageInfo _info;

  static Future<void> init() async {
    _info = await PackageInfo.fromPlatform();
  }

  static String get packageName => _info.packageName;
  static String get version => _info.version;
  static String get buildNumber => _info.buildNumber;
  static String get appName => _info.appName;
}
