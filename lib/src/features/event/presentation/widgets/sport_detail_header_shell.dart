import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

/// Provides the common pink-background shell used by every sport detail header.
///
/// Shows a fixed-height skeleton on loading/error; injects sport-specific
/// content via [builder] when data is available.
class SportDetailHeaderShell<T> extends StatelessWidget {
  const SportDetailHeaderShell({
    super.key,
    required this.detailAsync,
    required this.builder,
    this.skeletonHeight = 72.0,
    this.backgroundColor,
    this.fallback,
  });

  final AsyncValue<dynamic> detailAsync;
  final Widget Function(T detail) builder;
  final double skeletonHeight;
  final Color? backgroundColor;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      color: backgroundColor ?? context.appColors.accent,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: detailAsync.when(
        loading: () => fallback ?? SizedBox(height: skeletonHeight),
        error: (e, _) => fallback ?? SizedBox(height: skeletonHeight),
        data: (obj) => builder(obj as T),
      ),
    );
  }
}
