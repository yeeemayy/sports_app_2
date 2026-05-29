import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_card.dart';

class HomeAnchorLiveGrid extends StatelessWidget {
  const HomeAnchorLiveGrid({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.anchors,
    this.itemCount = 10,
  });

  final EdgeInsets padding;
  final List<AnchorModel>? anchors;
  final int itemCount;

  // Alternate heights for a staggered masonry feel
  static double _aspectRatio(int index) => index.isEven ? 0.62 : 0.80;

  @override
  Widget build(BuildContext context) {
    final count = anchors?.length ?? itemCount;
    final crossAxisCount = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      itemCount: count,
      itemBuilder: (context, index) {
        final child = anchors == null
            ? const HomeAnchorLiveCard.loading()
            : HomeAnchorLiveCard(
                anchor: anchors![index],
                onTap: () =>
                    context.push(AppRoutes.anchorPath(anchors![index].id)),
              );
        return AspectRatio(aspectRatio: _aspectRatio(index), child: child);
      },
    );
  }
}
