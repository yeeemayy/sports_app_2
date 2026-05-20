import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A scrollable list of skeleton-animated placeholder cards.
class ShimmerLoadingList extends StatelessWidget {
  const ShimmerLoadingList({super.key, this.itemCount = 8, this.itemHeight = 72});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        itemBuilder: (context, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}
