import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/shared_widgets/anchor_avatar.dart';

class HomeLiveEvents extends StatelessWidget {
  const HomeLiveEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        spacing: 6,
        children: [
          Text(
            '中国台湾UBA大专篮球联赛',
            style: context.textTheme.labelMedium?.copyWith(color: Colors.grey.shade500),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text('13:00', style: context.textTheme.labelMedium),
              Text(
                'Q4-08:49',
                style: context.textTheme.labelMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 6,
            children: [
              _buildContestee('黎明技术学院'),
              Text(
                '55-58',
                style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              _buildContestee('虎尾科技大学'),
            ],
          ),
          AnchorAvatar(size: 35)
        ],
      ),
    );
  }

  Widget _buildContestee(String contesteeName) => Column(
    children: [
      Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 3, color: Colors.grey.shade300),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: 'https://placehold.co/400x400/FFFFFF/898989.png?text=Image',
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: const ColoredBox(color: Colors.grey),
            ),
            errorWidget: (context, url, error) =>
                ColoredBox(color: Colors.grey.shade200),
          ),
        ),
      ),
      Text(contesteeName),
    ],
  );
}
