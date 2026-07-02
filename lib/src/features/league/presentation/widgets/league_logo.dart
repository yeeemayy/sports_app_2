import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';

class LeagueLogoWidget extends StatelessWidget {
  const LeagueLogoWidget({super.key, required this.logoUrl, this.size = 44});

  final String logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: context.appColors.surface2),
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.surface2,
          ),
          child: Icon(
            Icons.emoji_events_outlined,
            size: size * 0.45,
            color: context.appColors.text3,
          ),
        ),
      ),
    );
  }
}
