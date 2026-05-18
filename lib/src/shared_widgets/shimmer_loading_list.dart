import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

/// A scrollable list of shimmer-animated placeholder cards.
class ShimmerLoadingList extends StatelessWidget {
  const ShimmerLoadingList({super.key, this.itemCount = 8, this.itemHeight = 72});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, _) {
        return Shimmer.fromColors(
          baseColor: context.appTheme.shimmerBase,
          highlightColor: context.appTheme.shimmerHighlight,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
