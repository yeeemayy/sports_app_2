import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Centered icon + bold title + optional description, for empty list/data states.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    String? title,
    this.description,
    this.titleColor,
  }) : title = title ?? 'common.empty';

  final IconData icon;
  final String title;
  final String? description;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) => _StateLayout(
        icon: icon,
        iconColor: context.appColors.text3,
        title: title,
        description: description,
        titleColor: titleColor,
      );
}

/// Centered icon + bold title + optional description, for error states, with an optional retry action.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.icon = Icons.error_outline_rounded,
    String? title,
    this.description,
    this.onRetry,
    this.titleColor,
  }) : title = title ?? 'common.error_generic';

  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) => _StateLayout(
        icon: icon,
        iconColor: context.appColors.danger,
        title: title,
        description: description,
        onRetry: onRetry,
        titleColor: titleColor,
      );
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    this.onRetry,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 12),
              Text(
                title.tr(),
                textAlign: TextAlign.center,
                style: titleColor == null
                    ? AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)
                    : AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text).copyWith(color: titleColor),
              ),
              if (description != null) ...[
                const SizedBox(height: 6),
                Text(
                  description!.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(12).copyWith(color: context.appColors.text2),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TextButton(onPressed: onRetry, child: Text('common.retry'.tr())),
              ],
            ],
          ),
        ),
      );
}
