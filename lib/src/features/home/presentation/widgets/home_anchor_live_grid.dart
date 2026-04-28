import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/features/home/domain/models/anchor_model.dart';
import 'package:sports_app/src/features/home/presentation/widgets/home_anchor_live_card.dart';

class HomeAnchorLiveGrid extends StatelessWidget {
  const HomeAnchorLiveGrid({super.key,
    this.padding =  const EdgeInsets.symmetric(horizontal: 16.0),
    this.anchors, this.itemCount = 10});

  final EdgeInsets padding;
  final List<AnchorModel>? anchors;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final count = anchors?.length ?? itemCount;
    // final isTablet = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
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
