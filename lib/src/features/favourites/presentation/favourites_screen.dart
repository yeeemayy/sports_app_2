import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/favourites/data/favourites_repository.dart';
import 'package:shenghaotiyu/src/features/favourites/domain/favourite_entry.dart';
import 'package:shenghaotiyu/src/features/favourites/presentation/providers/favourites_providers.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_app_bar.dart';

const _kStarColor = Color(0xFFFFD60A);

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseUidProvider);
    if (uid == null) return const SizedBox.shrink();

    final teamsAsync = ref.watch(favouriteTeamsProvider(uid));
    final leaguesAsync = ref.watch(favouriteLeaguesProvider(uid));
    final colors = context.appColors;

    return Scaffold(
      appBar: CustomAppBar(title: Text('favourites.title'.tr())),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: _Section(
                label: 'favourites.section_leagues'.tr(),
                async: leaguesAsync,
                emptyText: 'favourites.empty_leagues'.tr(),
                type: FavouriteType.league,
                repo: ref.read(favouritesRepositoryProvider),
                uid: uid,
                onTap: (entry) => context.push(AppRoutes.leagueDetailPath(entry.sport, entry.id)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: _Section(
                label: 'favourites.section_teams'.tr(),
                async: teamsAsync,
                emptyText: 'favourites.empty_teams'.tr(),
                type: FavouriteType.team,
                repo: ref.read(favouritesRepositoryProvider),
                uid: uid,
                onTap: (entry) => context.push(AppRoutes.leagueTeamPath(entry.sport, entry.id)),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SafeArea(top: false, child: const SizedBox())),
        ],
      ),
    );
  }
}

// ── Section ────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.async,
    required this.emptyText,
    required this.type,
    required this.repo,
    required this.uid,
    required this.onTap,
  });

  final String label;
  final AsyncValue<List<FavouriteEntry>> async;
  final String emptyText;
  final FavouriteType type;
  final FavouritesRepository repo;
  final String uid;
  final void Function(FavouriteEntry) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            label,
            style: AppTextStyles.mono(11).copyWith(color: colors.text2, letterSpacing: 11 * 0.14),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line, width: 0.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: async.when(
            loading: () => _buildSkeleton(context),
            error: (_, _) => _buildEmpty(context),
            data: (items) => items.isEmpty
                ? _buildEmpty(context)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 0,
                            thickness: 0.5,
                            color: colors.line,
                            indent: 58,
                            endIndent: 0,
                          ),
                        _FavRow(
                          entry: items[i],
                          type: type,
                          repo: repo,
                          uid: uid,
                          onTap: () => onTap(items[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      child: Center(
        child: Text(
          emptyText,
          style: context.textTheme.bodySmall?.copyWith(color: context.appColors.text3),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: List.generate(
          2,
          (i) => _FavRow(
            entry: FavouriteEntry(
              id: 'skeleton_$i',
              sport: 'football',
              name: 'Loading Team Name',
              addedAt: DateTime.now(),
            ),
            type: type,
            repo: repo,
            uid: uid,
            onTap: () {},
          ),
        ),
      ),
    );
  }
}

// ── Row ────────────────────────────────────────────────────────────────────────

class _FavRow extends StatelessWidget {
  const _FavRow({
    required this.entry,
    required this.type,
    required this.repo,
    required this.uid,
    required this.onTap,
  });

  final FavouriteEntry entry;
  final FavouriteType type;
  final FavouritesRepository repo;
  final String uid;
  final VoidCallback onTap;

  Future<void> _unfavourite() async {
    if (type == FavouriteType.team) {
      await repo.toggleTeam(
        uid: uid,
        sport: entry.sport,
        teamId: entry.id,
        name: entry.name,
        cnName: entry.cnName,
        logoUrl: entry.logoUrl,
      );
    } else {
      await repo.toggleLeague(
        uid: uid,
        sport: entry.sport,
        leagueId: entry.id,
        name: entry.name,
        cnName: entry.cnName,
        logoUrl: entry.logoUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final displayName = context.localizedName(en: entry.name, cn: entry.cnName);
    final sportLabel = 'league.sport.${entry.sport}'.tr();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _Logo(logoUrl: entry.logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.text,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _SportTag(label: sportLabel, colors: colors),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _unfavourite,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.star_rounded, color: _kStarColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo ───────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo({this.logoUrl});
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: context.appColors.surface2),
        child: Icon(Icons.shield_outlined, size: 16, color: context.appColors.text3),
      );
    }
    return CachedNetworkImage(
      imageUrl: logoUrl!,
      width: 32,
      height: 32,
      imageBuilder: (_, imageProvider) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (_, _) => Skeletonizer(
        enabled: true,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.appColors.surface2),
        ),
      ),
      errorBuilder: (_, _, _) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: context.appColors.surface2),
        child: Icon(Icons.shield_outlined, size: 16, color: context.appColors.text3),
      ),
    );
  }
}

// ── Sport tag pill ─────────────────────────────────────────────────────────────

class _SportTag extends StatelessWidget {
  const _SportTag({required this.label, required this.colors});
  final String label;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.appColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          10,
        ).copyWith(color: context.appColors.accent, letterSpacing: 10 * 0.1),
      ),
    );
  }
}
