import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';

class SportStatusBadge extends StatefulWidget {
  const SportStatusBadge({
    super.key,
    required this.label,
    required this.isLive,
  });

  final String label;
  final bool isLive;

  @override
  State<SportStatusBadge> createState() => _SportStatusBadgeState();
}

class _SportStatusBadgeState extends State<SportStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkCtrl;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.isLive ? Colors.white : context.appColors.text3;
    final baseStyle = AppTextStyles.mono(9).copyWith(color: fg);
    final text = widget.label.toUpperCase();
    final hasApostrophe = widget.isLive && text.endsWith("'");
    final base = hasApostrophe ? text.substring(0, text.length - 1) : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: widget.isLive
            ? context.appColors.live
            : context.appColors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: hasApostrophe
          ? AnimatedBuilder(
              animation: _blinkCtrl,
              builder: (_, _) => RichText(
                text: TextSpan(
                  text: base,
                  style: baseStyle,
                  children: [
                    TextSpan(
                      text: "'",
                      style: baseStyle.copyWith(
                        color: fg.withValues(
                          alpha: _blinkCtrl.value < 0.5 ? 1.0 : 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Text(text, style: baseStyle),
    );
  }
}
