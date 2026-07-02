import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';

const _kRecommended = 'recommended';

class EventHomeHeader extends ConsumerWidget {
  const EventHomeHeader({super.key, required this.selectedFilter});

  final String selectedFilter;

  String get _heroAsset {
    if (selectedFilter == _kRecommended) return 'assets/images/shty_bg_main.jpeg';
    try {
      return SportType.values
          .firstWhere((s) => s.apiPath == selectedFilter)
          .heroAsset;
    } catch (_) {
      return 'assets/images/shty_bg_main.jpeg';
    }
  }

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'home.greeting.morning';
    if (h >= 12 && h < 17) return 'home.greeting.afternoon';
    return 'home.greeting.evening';
  }

  String _dateEyebrow(BuildContext context) {
    final now = DateTime.now();
    final locale = context.locale.toString();
    final isZh = context.locale.languageCode == 'zh';
    final pattern = isZh ? 'EEEE · MMMdd日' : 'EEE · dd MMM';
    final formatted = DateFormat(pattern, locale).format(now);
    return isZh ? formatted : formatted.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);
    final nickname = authAsync.valueOrNull?.user?.nickname ?? '';
    final displayName = nickname.isNotEmpty ? nickname.toUpperCase() : '';
    final heroAsset = _heroAsset;

    return ColoredBox(
      color: context.appColors.surface,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: -48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: Align(
                key: ValueKey(heroAsset),
                alignment: Alignment.centerRight,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.0, 0.55],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    heroAsset,
                    height: double.infinity,
                    width: MediaQuery.of(context).size.width * 0.6,
                    fit: BoxFit.cover,
                    color: Colors.white.withValues(alpha: 0.18),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.fromLTRB(22.0, 12, 22.0, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateEyebrow(context),
                    style: AppTextStyles.mono(10).copyWith(
                      color: context.appColors.text2,
                      letterSpacing: 10 * 0.18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.display(
                        32,
                        context,
                      ).copyWith(color: context.appColors.text),
                      children: [
                        TextSpan(text: _greetingKey().tr()),
                        if (displayName.isNotEmpty) ...[
                          TextSpan(text: ',\n'),
                          TextSpan(
                            text: displayName,
                            style: AppTextStyles.display(32, context).copyWith(
                              color: context.appColors.accent,
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
