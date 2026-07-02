import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/event/domain/models/sport_type.dart';
import 'package:shenghaotiyu/src/features/watchlist/domain/watchlist_entry.dart';
import 'package:shenghaotiyu/src/features/watchlist/presentation/providers/watchlist_notifier.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_app_bar.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_status_dialog.dart';

// Semantic accent for upcoming match chip — always green regardless of theme.
const _kCountdownAccent = Color(0xFF34D17F);

SportType? _sportTypeOf(String sport) {
  for (final s in SportType.values) {
    if (s.apiPath == sport) return s;
  }
  return null;
}

String _matchDetailPath(String sport, String matchId) {
  return switch (sport) {
    'football' => AppRoutes.footballMatchDetailPath(matchId),
    'basketball' => AppRoutes.basketballMatchDetailPath(matchId),
    'tennis' => AppRoutes.tennisMatchDetailPath(matchId),
    'badminton' => AppRoutes.badmintonMatchDetailPath(matchId),
    'table_tennis' => AppRoutes.tableTennisMatchDetailPath(matchId),
    'baseball' => AppRoutes.baseballMatchDetailPath(matchId),
    'volleyball' => AppRoutes.volleyballMatchDetailPath(matchId),
    'hockey' => AppRoutes.iceHockeyMatchDetailPath(matchId),
    'amfootball' => AppRoutes.amFootballMatchDetailPath(matchId),
    'cricket' => AppRoutes.cricketMatchDetailPath(matchId),
    _ => '',
  };
}

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  Timer? _timer;
  String? _activeSport; // null = all

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _confirmRemove(WatchlistEntry entry) async {
    final colors = context.appColors;
    await showCustomStatusDialog(
      context: context,
      dialogType: DialogType.custom,
      overrideIcon: Icons.notifications_off_outlined,
      overrideIconBackgroundColor: colors.accent,
      title: 'watchlist.remove_confirm_title'.tr(),
      description: 'watchlist.remove_confirm_body'.tr(),
      buttonText: 'watchlist.remove_confirm_button'.tr(),
      onButtonPressed: () {
        Navigator.of(context).pop();
        ref.read(watchlistNotifierProvider.notifier).remove(entry.matchId);
      },
      secondaryButton: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'watchlist.remove_cancel_button'.tr(),
          style: TextStyle(color: colors.text2),
        ),
      ),
      showCloseButton: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final watchlistAsync = ref.watch(watchlistNotifierProvider);

    return Scaffold(
      appBar: CustomAppBar(title: Text('watchlist.title'.tr())),
      backgroundColor: colors.ink,
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text('watchlist.load_error'.tr(), style: TextStyle(color: colors.text2)),
        ),
        data: (entries) {
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          final upcoming =
              entries
                  .where((e) => e.matchTimeMs > nowMs - const Duration(hours: 3).inMilliseconds)
                  .toList()
                ..sort((a, b) => a.matchTimeMs.compareTo(b.matchTimeMs));

          // Collect distinct sports present in the list.
          final sports = upcoming.map((e) => e.sport).toSet().toList()..sort();

          final filtered = _activeSport == null
              ? upcoming
              : upcoming.where((e) => e.sport == _activeSport).toList();

          return CustomScrollView(
            slivers: [
              if (sports.length >= 2)
                SliverToBoxAdapter(
                  child: _SportFilter(
                    sports: sports,
                    activeSport: _activeSport,
                    onSelected: (s) => setState(() => _activeSport = s),
                  ),
                ),
              if (filtered.isEmpty)
                SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          '${filtered.length} ${'watchlist.upcoming'.tr()}',
                          style: AppTextStyles.mono(12).copyWith(
                            color: colors.text3,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...filtered.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReminderCard(
                            entry: e,
                            onRemove: () => _confirmRemove(e),
                            onTap: () {
                              final path = _matchDetailPath(e.sport, e.matchId);
                              if (path.isNotEmpty) context.push(path);
                            },
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Sport filter ────────────────────────────────────────────────────────────────

class _SportFilter extends StatelessWidget {
  const _SportFilter({
    required this.sports,
    required this.activeSport,
    required this.onSelected,
  });
  final List<String> sports;
  final String? activeSport;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'watchlist.filter_all'.tr(),
            active: activeSport == null,
            onTap: () => onSelected(null),
            colors: colors,
          ),
          ...sports.map((s) {
            final sportType = _sportTypeOf(s);
            return _FilterChip(
              label: sportType != null ? sportType.i18nKey.tr() : s,
              icon: sportType?.icon,
              active: activeSport == s,
              onTap: () => onSelected(s == activeSport ? null : s),
              colors: colors,
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    required this.colors,
    this.icon,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final AppColors colors;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? colors.accent : colors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? colors.accent : colors.line,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: active ? Colors.white : colors.text2),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : colors.text2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.line, width: 0.5),
            ),
            child: Center(
              child: Icon(Icons.notifications_none_rounded, size: 30, color: colors.text3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'watchlist.empty_title'.tr(),
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: colors.text,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 220,
            child: Text(
              'watchlist.empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: colors.text3,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reminder card ──────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.entry, required this.onRemove, required this.onTap});
  final WatchlistEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final diff = entry.matchTime.difference(DateTime.now());
    final sportType = _sportTypeOf(entry.sport);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.line, width: 0.5),
        ),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League header row
            Row(
              children: [
                _GradientCrest(
                  name: entry.leagueName.isNotEmpty ? entry.leagueName : '?',
                  size: 18,
                  borderColor: colors.lineStrong,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    entry.leagueName.isNotEmpty ? entry.leagueName : '—',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: colors.text2,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (sportType != null) ...[
                  const SizedBox(width: 6),
                  _SportBadge(sportType: sportType, colors: colors),
                ],
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.notifications_off_outlined),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 13),

            // Teams + countdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TeamRow(name: entry.homeName, colors: colors),
                      const SizedBox(height: 9),
                      _VsDivider(colors: colors),
                      const SizedBox(height: 9),
                      _TeamRow(name: entry.awayName, colors: colors),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _CountdownChip(diff: diff),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sport badge ────────────────────────────────────────────────────────────────

class _SportBadge extends StatelessWidget {
  const _SportBadge({required this.sportType, required this.colors});
  final SportType sportType;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(sportType.icon, size: 11, color: colors.accent),
          const SizedBox(width: 4),
          Text(
            sportType.i18nKey.tr(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Team row ───────────────────────────────────────────────────────────────────

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.name, required this.colors});
  final String name;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GradientCrest(name: name, size: 28, borderColor: colors.lineStrong),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: colors.text,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── VS divider ─────────────────────────────────────────────────────────────────

class _VsDivider extends StatelessWidget {
  const _VsDivider({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            'VS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: colors.text3,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: colors.line)),
      ],
    );
  }
}

// ── Countdown chip ─────────────────────────────────────────────────────────────

class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.diff});
  final Duration diff;

  String get _text {
    if (diff.isNegative || diff.inSeconds <= 0) {
      return 'watchlist.chip_starting_now'.tr();
    }
    return 'watchlist.chip_starts_in'.tr(namedArgs: {'time': _formatTime(diff)});
  }

  static String _formatTime(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${mins}m';
    if (mins > 0) return '${mins}m';
    return '< 1m';
  }

  bool get _pulse => !diff.isNegative && diff.inMinutes < 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _kCountdownAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(pulse: _pulse),
          const SizedBox(width: 6),
          Text(
            _text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _kCountdownAccent,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.pulse});
  final bool pulse;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 1.0,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: _kCountdownAccent),
    );
    if (!widget.pulse) return dot;
    return FadeTransition(opacity: _anim, child: dot);
  }
}

// ── Gradient crest ─────────────────────────────────────────────────────────────

class _GradientCrest extends StatelessWidget {
  const _GradientCrest({required this.name, required this.size, required this.borderColor});
  final String name;
  final double size;
  final Color borderColor;

  Color _hashColor(int offset) {
    final h = (name.hashCode.abs() + offset) % 360;
    return HSLColor.fromAHSL(1.0, h.toDouble(), 0.65, 0.38).toColor();
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_hashColor(0), _hashColor(60)],
        ),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.1,
            shadows: [Shadow(blurRadius: 2, color: Colors.black.withValues(alpha: 0.4))],
          ),
        ),
      ),
    );
  }
}
