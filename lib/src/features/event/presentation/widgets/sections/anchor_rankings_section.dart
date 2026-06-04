import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/models/paginated_response.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/routes/app_routes.dart';

const _kHPad = 22.0;

class AnchorRankingsSection extends StatelessWidget {
  const AnchorRankingsSection({super.key, required this.anchorsAsync});

  final AsyncValue<PaginatedResponse<AnchorModel>> anchorsAsync;

  @override
  Widget build(BuildContext context) {
    return anchorsAsync.when(
      skipLoadingOnReload: true,
      loading: () => _shimmer(context),
      error: (_, _) => const SizedBox.shrink(),
      data: (page) {
        final anchors = page.data.take(6).toList();
        if (anchors.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'home.anchor_rankings'.tr(),
                    style: AppTextStyles.display(
                      22,
                      context,
                    ).copyWith(color: context.appColors.text),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.anchorList),
                    child: Text(
                      'home.see_all'.tr(),
                      style: AppTextStyles.mono(10).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 10 * 0.14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
                itemCount: anchors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) =>
                    _AnchorRankingItem(anchor: anchors[i]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _shimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 24),
      child: Skeletonizer(
        enabled: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(
              4,
              (_) => Container(
                width: 88,
                height: 118,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnchorRankingItem extends StatelessWidget {
  const _AnchorRankingItem({required this.anchor});

  final AnchorModel anchor;

  @override
  Widget build(BuildContext context) {
    final isLive = anchor.isLive == 1;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.anchorPath(anchor.id)),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            SizedBox(
              width: 78,
              height: 78,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLive
                              ? context.appColors.accent
                              : context.appColors.lineStrong,
                          width: isLive ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: anchor.avatarUrl,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: context.appColors.surface2),
                        errorBuilder: (_, _, _) => Container(
                          color: context.appColors.surface2,
                          child: Icon(
                            Icons.person,
                            color: context.appColors.text3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'home.anchor.live_badge'.tr(),
                            style: AppTextStyles.display(12, context).copyWith(
                              color: context.appColors.ink,
                              letterSpacing: 12 * 0.04,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anchor.nickname.toUpperCase(),
              style: AppTextStyles.display(11, context).copyWith(
                color: context.appColors.text,
                letterSpacing: 11 * 0.04,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
