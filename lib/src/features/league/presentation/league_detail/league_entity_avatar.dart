import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';

/// Circular team-logo avatar.
///
/// Returns [SizedBox.shrink] when [logoUrl] is null or empty, so callers can
/// drop it inline without a guard `if` statement (the zero-size widget has no
/// layout impact).
///
/// Set [circleFallback] to true (default) when a surface-coloured circle
/// should appear on network errors — used in standings tables.
/// Set it to false when errors should be silent — used in team-stats rows
/// and squad-team chip selectors.
class LeagueTeamAvatar extends StatelessWidget {
  const LeagueTeamAvatar({
    super.key,
    required this.logoUrl,
    required this.size,
    this.circleFallback = true,
  });

  final String? logoUrl;
  final double size;

  /// true → surface2 circle on error  |  false → SizedBox.shrink() on error
  final bool circleFallback;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => circleFallback
            ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.surface2,
                ),
              )
            : SizedBox(width: size, height: size),
      ),
    );
  }
}

/// Circular player-photo avatar with a person-icon fallback.
///
/// Always renders at [size] × [size] — never collapses to zero — so player
/// rows have a consistent left edge regardless of whether a photo is available.
class LeaguePlayerAvatar extends StatelessWidget {
  const LeaguePlayerAvatar({
    super.key,
    required this.logoUrl,
    required this.size,
  });

  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl ?? '',
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
            Icons.person,
            color: context.appColors.text3,
            size: size * 0.47,
          ),
        ),
      ),
    );
  }
}
