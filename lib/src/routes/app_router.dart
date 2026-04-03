import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/anchor/presentation/anchor_detail_screen.dart';
import 'package:sports_app/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:sports_app/src/features/auth/presentation/login_screen.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/auth/presentation/register_screen.dart';
import 'package:sports_app/src/features/data/presentation/data_screen.dart';
import 'package:sports_app/src/features/event/presentation/event_screen.dart';
import 'package:sports_app/src/features/home/presentation/home_screen.dart';
import 'package:sports_app/src/features/news/presentation/news_screen.dart';
import 'package:sports_app/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:sports_app/src/features/profile/presentation/profile_screen.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/routes/app_wrapper.dart';

part 'app_router.g.dart';

/// Global navigator key passed to GoRouter.
/// Used by interceptors and services that need to navigate or show dialogs
/// outside the widget tree.
final rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = _AuthNotifierListenable(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      if (authAsync.isLoading) return null;

      final isAuthenticated = authAsync.valueOrNull?.isAuthenticated ?? false;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return AppWrapper(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.event,
                builder: (BuildContext context, GoRouterState state) => const EventScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.news,
                builder: (BuildContext context, GoRouterState state) => const NewsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.data,
                builder: (BuildContext context, GoRouterState state) => const DataScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: AppRoutes.profileEdit,
                    builder: (BuildContext context, GoRouterState state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.anchor,
        builder: (context, state) => AnchorDetailScreen(
          anchorId: int.parse(state.pathParameters['anchorId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );
}

/// Bridges Riverpod auth state changes to GoRouter's Listenable-based refresh.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}
