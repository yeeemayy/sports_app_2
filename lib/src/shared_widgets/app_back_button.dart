import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';

/// Standard frosted circular back button used across the app.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
    this.size = 38,
    this.iconSize = 16,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap ?? () => context.pop(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor ?? colors.lineStrong, width: 0.5),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: iconColor ?? colors.text,
          size: iconSize,
        ),
      ),
    );
  }
}
