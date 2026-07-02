import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/core/models/paginated_response.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/home/domain/models/anchor_model.dart';
import 'package:shenghaotiyu/src/features/home/presentation/widgets/home_anchor_live_card.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

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
                  itemBuilder: (context, i) => HomeAnchorLiveCard(
                    anchor: anchors[i],
                    onTap: () => context.push(AppRoutes.anchorPath(anchors[i].id)),
                  ),
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
