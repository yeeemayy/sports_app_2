import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';

const _kHPad = 22.0;

class EmptyPersonalizationPrompt extends StatelessWidget {
  const EmptyPersonalizationPrompt({super.key, required this.onViewLive});

  final VoidCallback onViewLive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kHPad, 16, _kHPad, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.line, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home.empty_hub_title'.tr().toUpperCase(),
              style: AppTextStyles.display(16, context)
                  .copyWith(color: context.appColors.text),
            ),
            const SizedBox(height: 6),
            Text(
              'home.empty_hub_body'.tr(),
              style: AppTextStyles.mono(12).copyWith(
                color: context.appColors.text2,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: 'home.empty_hub_browse_leagues'.tr(),
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.go(AppRoutes.league),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    label: 'home.empty_hub_view_live'.tr(),
                    color: const Color(0xFF10B981),
                    onTap: onViewLive,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    label: 'home.empty_hub_search'.tr(),
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.push(AppRoutes.leagueSearch),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.mono(11).copyWith(
              color: color,
              letterSpacing: 9 * 0.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
