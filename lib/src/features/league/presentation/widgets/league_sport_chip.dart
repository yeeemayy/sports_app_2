import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/sport_type.dart';

class LeagueSportChip extends StatelessWidget {
  const LeagueSportChip({
    super.key,
    required this.sport,
    required this.active,
    required this.onTap,
  });

  final SportType sport;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? context.appColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? context.appColors.accent : context.appColors.line,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sport.icon,
              size: 20,
              color: active
                  ? context.appColors.accent
                  : context.appColors.text2,
            ),
            const SizedBox(height: 8),
            Text(
              sport.i18nKey.tr().toUpperCase(),
              style: AppTextStyles.mono(8).copyWith(
                color: active
                    ? context.appColors.accent
                    : context.appColors.text2,
                letterSpacing: 8 * 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
