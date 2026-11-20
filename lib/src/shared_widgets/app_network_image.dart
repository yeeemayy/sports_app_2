import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../core/theme/app_theme.dart';

/// Circular or rounded network image with a skeleton-loading / fallback-icon
/// state — used for every logo/avatar/cover slot in the Community feature.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.size,
    this.borderRadius,
    this.fallbackIcon = Icons.person_outline_rounded,
  });

  final String? url;
  final double size;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 2);
    if (url == null || url!.isEmpty) {
      return _placeholder(context, radius);
    }
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size.isFinite ? size : null,
        height: size.isFinite ? size : null,
        fit: BoxFit.cover,
        placeholder: (context, _) => Skeletonizer(
          enabled: true,
          child: Container(
            width: size.isFinite ? size : null,
            height: size.isFinite ? size : null,
            color: context.appColors.placeholder,
          ),
        ),
        errorBuilder: (context, url, error) => _placeholder(context, radius),
      ),
    );
  }

  Widget _placeholder(BuildContext context, BorderRadius radius) => Container(
    width: size.isFinite ? size : null,
    height: size.isFinite ? size : null,
    decoration: BoxDecoration(color: context.appColors.surface, borderRadius: radius),
    child: Icon(
      fallbackIcon,
      size: size.isFinite ? size * 0.5 : 32,
      color: context.appColors.text3,
    ),
  );
}
