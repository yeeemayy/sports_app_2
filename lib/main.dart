import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/utils/app_locale.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      title: 'Sports App',
      localizationsDelegates:[
        CountryLocalizations.delegate,
        ...context.localizationDelegates],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink).copyWith(primaryContainer: Colors.pink.shade50),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.grey.shade100,
          titleTextStyle: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.pink),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: TextButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white, minimumSize: Size(0, 48)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.pink),
            foregroundColor: Colors.pink,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.pink.shade50,
          indicatorColor: Colors.pink.shade300,
        )
      ),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
