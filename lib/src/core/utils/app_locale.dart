import 'package:flutter/widgets.dart';

/// A lightweight global accessor for the current app locale.
/// Updated by [MyApp] on every build so non-widget code (e.g. model parsers)
/// can read the active locale without needing a [BuildContext].
class AppLocale {
  AppLocale._();

  static Locale _current = const Locale('zh', 'CN');

  static Locale get current => _current;

  static void update(Locale locale) => _current = locale;

  static bool get isChinese => _current.languageCode == 'zh';
}
