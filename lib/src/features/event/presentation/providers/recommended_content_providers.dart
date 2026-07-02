import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shenghaotiyu/src/core/models/paginated_response.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_match.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/event/presentation/providers/event_providers.dart';
import 'package:shenghaotiyu/src/features/favourites/domain/favourite_entry.dart';
import 'package:shenghaotiyu/src/features/favourites/presentation/providers/favourites_providers.dart';
import 'package:shenghaotiyu/src/features/home/domain/models/anchor_model.dart';
import 'package:shenghaotiyu/src/features/home/presentation/providers/anchor_providers.dart';
import 'package:shenghaotiyu/src/features/news/domain/models/news_article.dart';
import 'package:shenghaotiyu/src/features/news/presentation/providers/news_providers.dart';
import 'package:shenghaotiyu/src/features/prediction/presentation/providers/prediction_providers.dart';
import 'package:shenghaotiyu/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:shenghaotiyu/src/features/watchlist/presentation/providers/watchlist_notifier.dart';

part 'recommended_content_providers.g.dart';

class RecommendedContentViewModel {
  const RecommendedContentViewModel({
    required this.newsAsync,
    required this.anchorsAsync,
    required this.liveAsync,
    required this.upcomingMatches,
    required this.favUpcoming,
    required this.favTeamNames,
    required this.allFavNames,
    required this.favSports,
  });

  final AsyncValue<List<NewsArticle>> newsAsync;
  final AsyncValue<PaginatedResponse<AnchorModel>> anchorsAsync;
  final AsyncValue<PaginatedMatchResult> liveAsync;
  final List<WatchlistEntry> upcomingMatches;
  final List<({SportMatch match, SportType sport})> favUpcoming;
  final Set<String> favTeamNames;
  final Set<String> allFavNames;
  final Set<SportType> favSports;
}

@riverpod
RecommendedContentViewModel recommendedContentViewModel(
  RecommendedContentViewModelRef ref,
  String localeCode,
) {
  final newsAsync = ref.watch(newsFirstPageProvider(localeCode));
  final anchorsAsync = ref.watch(anchorListProvider());
  final liveAsync = ref.watch(
    sportMatchesPaginatedProvider(sport: SportType.football, matchStatus: 'live'),
  );

  final uid = ref.watch(firebaseUidProvider);
  final watchlistEntries =
      ref.watch(watchlistNotifierProvider).valueOrNull ?? const <WatchlistEntry>[];
  final favTeams = uid != null
      ? (ref.watch(favouriteTeamsProvider(uid)).valueOrNull ?? const <FavouriteEntry>[])
      : const <FavouriteEntry>[];
  final favLeagues = uid != null
      ? (ref.watch(favouriteLeaguesProvider(uid)).valueOrNull ?? const <FavouriteEntry>[])
      : const <FavouriteEntry>[];

  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final upcomingMatches = watchlistEntries
      .where((e) => e.matchTimeMs > nowMs - const Duration(hours: 1).inMilliseconds)
      .toList()
    ..sort((a, b) => a.matchTimeMs.compareTo(b.matchTimeMs));

  final favTeamNames = <String>{
    for (final t in favTeams) ...[
      t.name.toLowerCase(),
      if (t.cnName != null && t.cnName!.isNotEmpty) t.cnName!.toLowerCase(),
    ],
  };

  final allFavNames = <String>{
    ...favTeamNames,
    for (final l in favLeagues) ...[
      l.name.toLowerCase(),
      if (l.cnName != null && l.cnName!.isNotEmpty) l.cnName!.toLowerCase(),
    ],
  };

  final watchlistedIds = {for (final e in watchlistEntries) e.matchId};
  final favSports = favTeams
      .map((t) => SportType.values.where((s) => s.apiPath == t.sport).firstOrNull)
      .whereType<SportType>()
      .toSet();

  final favUpcoming = <({SportMatch match, SportType sport})>[];
  for (final sportType in favSports) {
    final upcoming = ref
            .watch(
              sportMatchesPaginatedProvider(sport: sportType, matchStatus: 'upcoming'),
            )
            .valueOrNull
            ?.items ??
        [];
    for (final m in upcoming) {
      if (watchlistedIds.contains(m.id)) continue;
      final home = m.homeName.toLowerCase();
      final away = m.awayName.toLowerCase();
      if (favTeamNames.any((n) => n.isNotEmpty && (home.contains(n) || away.contains(n)))) {
        favUpcoming.add((match: m, sport: sportType));
      }
    }
  }
  favUpcoming.sort((a, b) => (a.match.matchTime ?? 0).compareTo(b.match.matchTime ?? 0));

  return RecommendedContentViewModel(
    newsAsync: newsAsync,
    anchorsAsync: anchorsAsync,
    liveAsync: liveAsync,
    upcomingMatches: upcomingMatches,
    favUpcoming: favUpcoming,
    favTeamNames: favTeamNames,
    allFavNames: allFavNames,
    favSports: favSports,
  );
}
