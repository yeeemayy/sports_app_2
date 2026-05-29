import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

class AnchorAvatar extends StatelessWidget {
  final double size;
  final bool isLive;
  const AnchorAvatar({super.key, this.size = 60, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 1, color: Colors.grey.shade300),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl:
                  'https://placehold.co/400x400/FFFFFF/898989.png?text=Image',
              fit: BoxFit.cover,
              placeholder: (context, url) => Skeletonizer(
                enabled: true,
                child: const ColoredBox(color: Colors.grey),
              ),
              errorWidget: (context, url, error) =>
                  ColoredBox(color: Colors.grey.shade200),
            ),
          ),
        ),
        Positioned(
          bottom: -4,
          child: Badge(
            padding: EdgeInsets.symmetric(horizontal: 6),
            label: Text(
              'anchor.detail.live'.tr(),
              style: TextStyle(fontSize: 12 * (size / 60)),
            ),
            backgroundColor: context.appColors.accent,
          ),
        ),
      ],
    );
  }
}

class AvatarFallback extends StatelessWidget {
  final double size;
  final double iconSize;

  const AvatarFallback({super.key, this.size = 100, this.iconSize = 48});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      width: size,
      height: size,
      child: Icon(Icons.person, size: iconSize, color: Colors.grey.shade400),
    );
  }
}
