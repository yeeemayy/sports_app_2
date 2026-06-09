import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:sports_app/src/features/watchlist/presentation/providers/watchlist_notifier.dart';

class LivePulseBadge extends StatefulWidget {
  const LivePulseBadge({super.key, required this.liveMinute});

  final String? Function() liveMinute;

  @override
  State<LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<LivePulseBadge>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final AnimationController _blinkCtrl;
  late final Timer _ticker;
  String? _liveMinute;

  @override
  void initState() {
    super.initState();
    _liveMinute = widget.liveMinute();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = widget.liveMinute();
      if (next != _liveMinute) setState(() => _liveMinute = next);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _ctrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_anim, _blinkCtrl]),
      builder: (_, _) {
        final text = _liveMinute ?? 'event.football.ht'.tr();
        final hasApostrophe = text.endsWith("'");
        final base = hasApostrophe ? text.substring(0, text.length - 1) : text;
        final apostropheOpacity = _blinkCtrl.value < 0.5 ? 1.0 : 0.0;
        final baseStyle = AppTextStyles.mono(9).copyWith(
          color: Colors.white,
          letterSpacing: 9 * 0.12,
          fontWeight: FontWeight.w700,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.appColors.live.withValues(
              alpha: 0.85 + 0.15 * _anim.value,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.4 + 0.6 * _anim.value,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              RichText(
                text: TextSpan(
                  text: base.toUpperCase(),
                  style: baseStyle,
                  children: hasApostrophe
                      ? [
                          TextSpan(
                            text: "'",
                            style: baseStyle.copyWith(
                              color: Colors.white.withValues(
                                alpha: apostropheOpacity,
                              ),
                            ),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SectionChip extends StatelessWidget {
  const SectionChip({super.key, required this.label, this.accent = false});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x800E0E0E),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent
              ? context.appColors.accent
              : context.appColors.lineStrong,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(10).copyWith(
          color: accent ? context.appColors.accent : context.appColors.text2,
          letterSpacing: 10 * 0.14,
        ),
      ),
    );
  }
}

class TimeBadge extends StatelessWidget {
  const TimeBadge({super.key, required this.matchTime});

  final DateTime matchTime;

  @override
  Widget build(BuildContext context) {
    final diff = matchTime.difference(DateTime.now());
    final isPast = diff.isNegative;
    final label = isPast ? 'LIVE?' : DateFormat('HH:mm').format(matchTime);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPast
            ? context.appColors.live.withValues(alpha: 0.9)
            : context.appColors.surface2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(9).copyWith(
          color: isPast ? context.appColors.ink : context.appColors.text2,
          letterSpacing: 9 * 0.12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ReasonLabel extends StatelessWidget {
  const ReasonLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.appColors.surface2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.mono(8).copyWith(
          color: context.appColors.text3,
          letterSpacing: 8 * 0.12,
        ),
      ),
    );
  }
}

class CompactBell extends ConsumerWidget {
  const CompactBell({super.key, required this.entry});

  final WatchlistEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(watchlistNotifierProvider.notifier);
    final isWatchlisted = ref.watch(
      watchlistNotifierProvider.select(
        (s) => s.valueOrNull?.any((e) => e.matchId == entry.matchId) ?? false,
      ),
    );
    return GestureDetector(
      onTap: () {
        if (isWatchlisted) {
          notifier.remove(entry.matchId);
        } else {
          notifier.add(entry);
        }
      },
      child: Icon(
        isWatchlisted
            ? Icons.notifications_active_rounded
            : Icons.notifications_outlined,
        size: 15,
        color: isWatchlisted ? context.appColors.accent : context.appColors.text3,
      ),
    );
  }
}
