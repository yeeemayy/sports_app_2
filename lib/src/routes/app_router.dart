import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_wrapper.dart';
import 'package:sports_app/src/features/home/presentation/home_screen.dart';
import 'package:sports_app/src/features/event/presentation/event_screen.dart';
import 'package:sports_app/src/features/news/presentation/news_screen.dart';
import 'package:sports_app/src/features/data/presentation/data_screen.dart';
import 'package:sports_app/src/features/profile/presentation/profile_screen.dart';
import 'package:sports_app/src/features/anchor/presentation/anchor_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppWrapper(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/event',
          builder: (context, state) => const EventScreen(),
        ),
        GoRoute(
          path: '/news',
          builder: (context, state) => const NewsScreen(),
        ),
        GoRoute(
          path: '/data',
          builder: (context, state) => const DataScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/anchor/:anchorId',
      builder: (context, state) => AnchorDetailScreen(
        anchorId: int.parse(state.pathParameters['anchorId']!),
      ),
    ),
  ],
);
