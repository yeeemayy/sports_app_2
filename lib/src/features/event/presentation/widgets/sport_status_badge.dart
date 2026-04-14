import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';

/// Pill-shaped status badge used in sport match cards.
///
/// [label] — localised status string; shows a generic fallback when empty.
/// [isLive] — when true, uses orange background with white text; grey otherwise.
class SportStatusBadge extends StatelessWidget {
  const SportStatusBadge({
    required this.label,
    required this.isLive,
    super.key,
  });

  final String label;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label.isNotEmpty ? label : 'common.unknown'.tr();
    final bgColor = isLive ? Colors.orange : Colors.grey.shade100;
    final textColor = isLive ? Colors.white : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        effectiveLabel,
        style: context.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
