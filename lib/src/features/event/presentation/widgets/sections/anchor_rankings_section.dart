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
const _kGap = 10.0;

class AnchorRankingsSection extends StatelessWidget {
  const AnchorRankingsSection({super.key, required this.anchorsAsync});

  final AsyncValue<PaginatedResponse<AnchorModel>> anchorsAsync;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: anchorsAsync.when(
        skipLoadingOnReload: true,
        loading: () => _shimmer(context),
        error: (_, _) => const SizedBox.shrink(),
        data: (page) {
          final anchors = page.data.take(4).toList();
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
                        style: AppTextStyles.mono(
                          10,
                        ).copyWith(color: context.appColors.text3, letterSpacing: 10 * 0.14),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(_kHPad, 0, _kHPad, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: _kGap,
                    mainAxisSpacing: _kGap,
                    childAspectRatio: 4 / 3,
                  ),
                  itemCount: anchors.length,
                  itemBuilder: (context, i) => _AnchorGridItem(anchor: anchors[i]),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _shimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 4, _kHPad, 24),
      child: Skeletonizer(
        enabled: true,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: _kGap,
            mainAxisSpacing: _kGap,
            childAspectRatio: 16 / 9,
          ),
          itemCount: 4,
          itemBuilder: (context, _) => Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnchorGridItem extends StatelessWidget {
  const _AnchorGridItem({required this.anchor});

  final AnchorModel anchor;

  @override
  Widget build(BuildContext context) {
    final isLive = anchor.isLive == 1;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.anchorPath(anchor.id)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image — use Image.network per project convention
            // for anchor covers that may change without URL change
            Image.network(
              anchor.cover,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: context.appColors.surface2,
                child: Icon(Icons.person, color: context.appColors.text3, size: 32),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: context.appColors.surface2);
              },
            ),
            // Bottom gradient + nickname + title
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            anchor.nickname,
                            style: AppTextStyles.display(
                              14,
                              context,
                            ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (anchor.title.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              anchor.title,
                              style: AppTextStyles.mono(
                                11,
                              ).copyWith(color: Colors.white.withValues(alpha: 0.8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isLive ? context.appColors.accent : Colors.grey.shade300,
                      child: Image.asset(
                        'assets/images/equalizer.gif',
                        color: Colors.white,
                        height: 16,
                        width: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Live badge (top-left)
            if (isLive)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.appColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'home.anchor.live_badge'.tr(),
                    style: AppTextStyles.display(9, context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 9 * 0.04,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
