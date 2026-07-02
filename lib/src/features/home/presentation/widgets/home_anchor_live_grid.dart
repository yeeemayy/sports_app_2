import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/features/home/domain/models/anchor_model.dart';
import 'package:shenghaotiyu/src/features/home/presentation/widgets/home_anchor_live_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final count = anchors?.length ?? itemCount;
    final crossAxisCount = MediaQuery.sizeOf(context).width >= 600 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 4 / 3,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        if (anchors == null) return const HomeAnchorLiveCard.loading();
        return HomeAnchorLiveCard(
          anchor: anchors![index],
          onTap: () => context.push(AppRoutes.anchorPath(anchors![index].id)),
        );
      },
    );
  }
}
