import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sports_app/src/core/utils/app_info.dart';
import 'package:sports_app/src/core/utils/app_locale.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_app/src/providers/theme_provider.dart';
import 'package:sports_app/src/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: '.env');
  await EasyLocalization.ensureInitialized();
  await AppInfo.init();
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
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocale.update(context.locale);
    final themeMode = ref.watch(themeModeProvider);
    final lightTitleStyle = context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87);
    final darkTitleStyle = context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        ),
        breakpoints: [
          Breakpoint(start: 0, end: 599, name: MOBILE),
          Breakpoint(start: 600, end: 1199, name: TABLET),
          Breakpoint(start: 1200, end: double.infinity, name: DESKTOP),
        ],
      ),
      title: 'Sports App',
      localizationsDelegates: [CountryLocalizations.delegate, ...context.localizationDelegates],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ).copyWith(primaryContainer: AppColors.primaryShade50),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0.5,
          shadowColor: Colors.grey.shade100,
          titleTextStyle: lightTitleStyle,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.primaryShade50,
          indicatorColor: AppColors.primaryShade300,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(primaryContainer: AppColors.primaryShade300),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0.5,
          titleTextStyle: darkTitleStyle,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: AppColors.primaryShade300,
        ),
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
