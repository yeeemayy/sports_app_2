import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';

/// Team or player logo with a shimmer placeholder and [AvatarFallback].
///
/// Set [circular] to `true` for round player avatars (uses [BoxFit.cover]).
/// Defaults to square with [BoxFit.contain].
class SportLogo extends StatelessWidget {
  const SportLogo({super.key, required this.url, required this.size, this.circular = false});

  final String? url;
  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final effective = url ?? '';
    Widget child;
    if (effective.isEmpty) {
      child = AvatarFallback(size: size, iconSize: size * 0.5);
    } else {
      child = CachedNetworkImage(
        imageUrl: effective,
        width: size,
        height: size,
        fit: circular ? BoxFit.cover : BoxFit.contain,
        placeholder: (_, _) => Shimmer.fromColors(
          baseColor: const Color(0xFFE0E0E0),
          highlightColor: const Color(0xFFF5F5F5),
          child: AvatarFallback(size: size, iconSize: size * 0.5),
        ),
        errorBuilder: (_, _, _) => AvatarFallback(size: size, iconSize: size * 0.5),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: circular ? ClipOval(child: child) : child,
    );
  }
}

/// Small circular league / tournament emblem.
///
/// Shows an empty [SizedBox] when [url] is empty or fails to load.
/// No shimmer — league logos are decorative and non-critical.
class LeagueLogo extends StatelessWidget {
  const LeagueLogo({super.key, required this.url, this.size = 16.0});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return SizedBox(width: size, height: size);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
      ),
    );
  }
}
