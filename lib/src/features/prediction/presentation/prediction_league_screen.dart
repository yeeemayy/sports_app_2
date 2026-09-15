import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shenghaotiyu/src/core/remote_config_provider.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/features/prediction/domain/prediction_model.dart';
import 'package:shenghaotiyu/src/features/prediction/presentation/providers/prediction_providers.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_app_bar.dart';

class PredictionLeagueScreen extends ConsumerWidget {
  const PredictionLeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final uid = ref.watch(firebaseUidProvider);

    return Scaffold(
      appBar: CustomAppBar(title: Text('prediction.league.title'.tr())),
      backgroundColor: colors.ink,
      body: uid == null
          ? _EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'prediction.league.login_required_title'.tr(),
              subtitle: 'prediction.league.login_required_subtitle'.tr(),
              colors: colors,
            )
          : ref
                .watch(predictionStatsProvider(uid))
                .when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) {
                    return _EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'prediction.league.load_error'.tr(),
                    subtitle: '',
                    colors: colors,
                  );},
                  data: (stats) => stats.total == 0
                      ? _EmptyState(
                          icon: Icons.sports_soccer_rounded,
                          title: 'prediction.league.empty_title'.tr(),
                          subtitle: 'prediction.league.empty_subtitle'.tr(),
                          colors: colors,
                        )
                      : _StatsBody(
                          stats: stats,
                          redemptions: ref.watch(predictionRedemptionsProvider),
                          colors: colors,
                        ),
                ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats, required this.redemptions, required this.colors});

  final PredictionStats stats;
  final List<Map<String, dynamic>> redemptions;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'prediction.league.points'.tr(),
                value: '${stats.points}',
                colors: colors,
                highlight: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'prediction.league.streak'.tr(),
                value: '${stats.streak}',
                colors: colors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'prediction.league.best_streak'.tr(),
                value: '${stats.bestStreak}',
                colors: colors,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'prediction.league.accuracy'.tr(),
                value: '${(stats.accuracy * 100).round()}%',
                colors: colors,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, size: 20, color: colors.text2),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'prediction.league.record'.tr(
                    namedArgs: {'correct': '${stats.correct}', 'total': '${stats.total}'},
                  ),
                  style: TextStyle(color: colors.text2, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'prediction.league.redemption_history'.tr(),
          style: AppTextStyles.mono(11).copyWith(color: colors.text3, letterSpacing: 0.1 * 11),
        ),
        const SizedBox(height: 10),
        ...redemptions.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RedemptionTile(redemption: _Redemption.fromJson(r), colors: colors),
          ),
        ),
      ],
    );
  }
}

class _Redemption {
  const _Redemption({required this.product, required this.points, required this.date});

  factory _Redemption.fromJson(Map<String, dynamic> json) => _Redemption(
    product: json['product'] as String,
    points: json['points'] as int,
    date: json['date'] as String,
  );

  final String product;
  final int points;
  final String date;
}

class _RedemptionTile extends StatelessWidget {
  const _RedemptionTile({required this.redemption, required this.colors});

  final _Redemption redemption;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.line, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.card_giftcard_rounded, size: 20, color: colors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.product,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  redemption.date,
                  style: TextStyle(fontSize: 12, color: colors.text3),
                ),
              ],
            ),
          ),
          Text(
            'prediction.league.redemption_points'.tr(namedArgs: {'points': '${redemption.points}'}),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.text2),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.colors,
    this.highlight = false,
  });

  final String label;
  final String value;
  final AppColors colors;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: highlight ? colors.accent.withValues(alpha: 0.12) : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? colors.accent.withValues(alpha: 0.3) : colors.line,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.display(
              28,
              context,
            ).copyWith(color: highlight ? colors.accent : colors.text),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.mono(10).copyWith(color: colors.text3, letterSpacing: 0.1 * 10),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
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
            child: Center(child: Icon(icon, size: 30, color: colors.text3)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: colors.text,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 7),
            SizedBox(
              width: 220,
              child: Text(
                subtitle,
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
        ],
      ),
    );
  }
}
