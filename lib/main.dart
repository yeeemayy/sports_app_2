import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shenghaotiyu/src/core/utils/app_info.dart';
import 'package:shenghaotiyu/src/core/utils/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shenghaotiyu/src/features/watchlist/data/notification_service.dart';
import 'package:shenghaotiyu/src/providers/theme_provider.dart';
import 'package:shenghaotiyu/src/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  await AppInfo.init();
  await NotificationService().init();
  await NotificationService().requestPermissions();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'GB')],
        path: 'assets/translations',
        fallbackLocale: const Locale('zh', 'CN'),
        startLocale: const Locale('zh', 'CN'),
        child: const ShenghaoSportsApp(),
      ),
    ),
  );
}

class ShenghaoSportsApp extends ConsumerWidget {
  const ShenghaoSportsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocale.update(context.locale);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        ),
        breakpoints: [
          Breakpoint(start: 0, end: 599, name: MOBILE),
          Breakpoint(start: 600, end: 1199, name: TABLET),
          Breakpoint(start: 1200, end: double.infinity, name: DESKTOP),
        ],
      ),
      title: '胜好体育',
      localizationsDelegates: [
        CountryLocalizations.delegate,
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: themeMode,
      theme: ThemeData(
        extensions: const [AppColors.light],
        scaffoldBackgroundColor: AppColors.light.ink,
        dividerColor: AppColors.light.lineStrong,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.light.accent,
              brightness: Brightness.light,
            ).copyWith(
              surface: AppColors.light.surface,
              primary: AppColors.light.accent,
              onPrimary: AppColors.light.surface,
              primaryContainer: AppColors.light.surface2,
            ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.light.ink,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            color: AppColors.light.text,
            fontSize: 16,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.light.accent),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.light.accent,
            foregroundColor: Colors.white,
            minimumSize: Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.light.accent),
            foregroundColor: AppColors.light.accent,
          ),
        ),
      ),
      darkTheme: ThemeData(
        extensions: const [AppColors.dark],
        scaffoldBackgroundColor: AppColors.dark.ink,
        dividerColor: AppColors.dark.lineStrong,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: AppColors.dark.accent,
              brightness: Brightness.dark,
            ).copyWith(
              surface: AppColors.dark.surface,
              primary: AppColors.dark.accent,
              onPrimary: AppColors.dark.ink,
            ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            color: AppColors.dark.text,
            fontSize: 16,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.dark.accent),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.dark.accent,
            foregroundColor: Colors.white,
            minimumSize: Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.dark.accent),
            foregroundColor: AppColors.dark.accent,
          ),
        ),
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
