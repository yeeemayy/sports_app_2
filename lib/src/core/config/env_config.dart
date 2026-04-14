import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String get baseUrl => dotenv.get('ZY_2026_BASE_URL');
  static String get secretKey => dotenv.get('ZY_SECRET_KEY');
  static String get appId => dotenv.get('ZY_2026_APP_ID');
  static String get aiscoreSportUrl => dotenv.get('AISCORE_SPORT');
  static String get newsApiUrl => dotenv.get('NEWS_API_URL');
}
