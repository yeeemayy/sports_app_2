import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sports_app/src/features/anchor/presentation/anchor_detail_screen.dart';
import 'package:sports_app/src/features/home/presentation/anchor_list_screen.dart';
import 'package:sports_app/src/features/event/presentation/am_football_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/basketball_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/cricket_match_detail_screen.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/presentation/football_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/badminton_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/baseball_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/ice_hockey_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/table_tennis_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/tennis_match_detail_screen.dart';
import 'package:sports_app/src/features/event/presentation/volleyball_match_detail_screen.dart';
import 'package:sports_app/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:sports_app/src/features/auth/presentation/login_screen.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/auth/presentation/register_screen.dart';
import 'package:sports_app/src/features/data/presentation/data_screen.dart';
import 'package:sports_app/src/features/event/presentation/event_screen.dart';
import 'package:sports_app/src/features/home/presentation/anchor_screen.dart';
import 'package:sports_app/src/features/news/presentation/news_detail_screen.dart';
import 'package:sports_app/src/features/video/presentation/video_detail_screen.dart';
import 'package:sports_app/src/features/news/presentation/news_screen.dart';
import 'package:sports_app/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:sports_app/src/features/profile/presentation/profile_screen.dart';
import 'package:sports_app/src/shared_widgets/web_view_screen.dart';
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
        builder:
            (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
              return AppWrapper(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) => const EventScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.anchor,
                builder: (BuildContext context, GoRouterState state) => const AnchorScreen(),
                routes: [
                  GoRoute(
                    path: '/anchor-list',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AnchorListScreen(),
                    routes: [
                      GoRoute(
                        path: '/:anchorId',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => AnchorDetailScreen(
                          anchorId: int.parse(state.pathParameters['anchorId']!),
                        ),
                      ),
                    ],
                  ),
                ],
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
          // StatefulShellBranch(
          //   routes: <RouteBase>[
          //     GoRoute(
          //       path: AppRoutes.data,
          //       builder: (BuildContext context, GoRouterState state) => const DataScreen(),
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: AppRoutes.profileEdit,
                    builder: (BuildContext context, GoRouterState state) =>
                        const EditProfileScreen(),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'privacy-policy',
                    builder: (context, state) => WebViewScreen(
                      url: 'https://qdty.gsport.day/privacy-policy.html',
                      title: state.extra as String? ?? '',
                    ),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'user-agreement',
                    builder: (context, state) => WebViewScreen(
                      url: 'https://qdty.gsport.day/user-agreement.html',
                      title: state.extra as String? ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.footballMatchDetail,
        builder: (context, state) => FootballMatchDetailScreen(
          matchId: state.pathParameters['matchId']!,
          initialMatch: state.extra as FootballMatch?,
        ),
      ),
      GoRoute(
        path: AppRoutes.basketballMatchDetail,
        builder: (context, state) =>
            BasketballMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.tennisMatchDetail,
        builder: (context, state) =>
            TennisMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.badmintonMatchDetail,
        builder: (context, state) =>
            BadmintonMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.tableTennisMatchDetail,
        builder: (context, state) =>
            TableTennisMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.baseballMatchDetail,
        builder: (context, state) =>
            BaseballMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.volleyballMatchDetail,
        builder: (context, state) =>
            VolleyballMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.iceHockeyMatchDetail,
        builder: (context, state) =>
            IceHockeyMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.amFootballMatchDetail,
        builder: (context, state) =>
            AmFootballMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.cricketMatchDetail,
        builder: (context, state) =>
            CricketMatchDetailScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: AppRoutes.newsDetail,
        builder: (context, state) =>
            NewsDetailScreen(newsId: int.parse(state.pathParameters['newsId']!)),
      ),
      GoRoute(
        path: AppRoutes.videoDetail,
        builder: (context, state) => VideoDetailScreen(
          videoId: int.parse(state.pathParameters['videoId']!),
          currentPage: int.tryParse(state.uri.queryParameters['page'] ?? '') ?? 1,
          lastPage: int.tryParse(state.uri.queryParameters['lastPage'] ?? '') ?? 1,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final encoded = state.uri.queryParameters['returnPath'];
          return LoginScreen(returnPath: encoded != null ? Uri.decodeComponent(encoded) : null);
        },
      ),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
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
