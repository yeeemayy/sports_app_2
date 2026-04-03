import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_card.dart';

class HomeAnchorLiveGrid extends StatelessWidget {
  const HomeAnchorLiveGrid({super.key, this.anchors, this.itemCount = 6});

  final List<AnchorModel>? anchors;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final count = anchors?.length ?? itemCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: count,
      itemBuilder: (context, index) => anchors == null
          ? const HomeAnchorLiveCard.loading()
          : HomeAnchorLiveCard(
              anchor: anchors![index],
              onTap: () => context.push(AppRoutes.anchorPath(anchors![index].id)),
            ),
    );
  }
}
