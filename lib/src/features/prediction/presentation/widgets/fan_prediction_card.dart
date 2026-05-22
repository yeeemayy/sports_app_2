import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/prediction/domain/prediction_model.dart';
import 'package:sports_app/src/features/prediction/presentation/providers/prediction_providers.dart';

/// Fan prediction voting card for Football and Basketball detail screens.
///
/// [hasDraw] — true for football (home/draw/away), false for basketball (home/away).
/// [homeName] / [awayName] — short team names shown on the vote bars.
/// [isMatchEnded] — when true the card is read-only (voting locked).
class FanPredictionCard extends ConsumerWidget {
  const FanPredictionCard({
    super.key,
    required this.matchId,
    required this.homeName,
    required this.awayName,
    this.hasDraw = true,
    this.isMatchEnded = false,
  });

  final String matchId;
  final String homeName;
  final String awayName;
  final bool hasDraw;
  final bool isMatchEnded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final firebaseUid = ref.watch(firebaseUidProvider);
    final isLoggedIn = ref.watch(authNotifierProvider).valueOrNull?.user != null;

    final tallyAsync = ref.watch(predictionTallyProvider(matchId));
    final userVoteAsync = firebaseUid != null
        ? ref.watch(userVoteProvider((matchId: matchId, uid: firebaseUid)))
        : const AsyncData<PredictionPick?>(null);

    final tally = tallyAsync.valueOrNull ?? const PredictionTally();
    final userPick = userVoteAsync.valueOrNull;

    final options = _buildOptions(homeName, awayName);
    final hasVoted = userPick != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.line, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              Text(
                'prediction.title'.tr(),
                style: AppTextStyles.display(14, context)
                    .copyWith(color: colors.text),
              ),
              const Spacer(),
              if (hasVoted)
                Text(
                  'prediction.picks'.tr(
                    namedArgs: {'n': _formatCount(tally.total)},
                  ),
                  style: AppTextStyles.mono(9).copyWith(
                    color: colors.text3,
                    letterSpacing: 0.14 * 9,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Vote bars
          ...options.map((opt) {
            if (!hasDraw && opt.pick == PredictionPick.draw) {
              return const SizedBox.shrink();
            }
            final pct = _pctFor(opt.pick, tally);
            final isSelected = userPick == opt.pick;
            final canVote = !isMatchEnded && firebaseUid != null && isLoggedIn && !hasVoted;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _VoteBar(
                label: opt.label,
                pct: pct,
                isSelected: isSelected,
                hasVoted: hasVoted,
                canVote: canVote,
                onTap: canVote
                    ? () => ref
                        .read(predictionRepositoryProvider)
                        .vote(
                          matchId: matchId,
                          uid: firebaseUid,
                          pick: opt.pick,
                        )
                    : null,
                colors: colors,
                context: context,
              ),
            );
          }),

          if (isMatchEnded)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'prediction.locked'.tr(),
                style: AppTextStyles.mono(9).copyWith(
                  color: colors.text3,
                  letterSpacing: 0.1 * 9,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (!isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'prediction.login_required'.tr(),
                style: AppTextStyles.mono(9).copyWith(
                  color: colors.text3,
                  letterSpacing: 0.1 * 9,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (!hasVoted)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'prediction.vote_to_see'.tr(),
                style: AppTextStyles.mono(9).copyWith(
                  color: colors.text3,
                  letterSpacing: 0.1 * 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  double _pctFor(PredictionPick pick, PredictionTally tally) {
    if (tally.total == 0) return 0;
    return switch (pick) {
      PredictionPick.home => tally.homePct,
      PredictionPick.draw => tally.drawPct,
      PredictionPick.away => tally.awayPct,
    };
  }

  List<_PredictionOption> _buildOptions(String home, String away) => [
    _PredictionOption(
      pick: PredictionPick.home,
      label: 'prediction.team_win'.tr(namedArgs: {'team': home}),
    ),
    _PredictionOption(
      pick: PredictionPick.draw,
      label: 'prediction.draw'.tr(),
    ),
    _PredictionOption(
      pick: PredictionPick.away,
      label: 'prediction.team_win'.tr(namedArgs: {'team': away}),
    ),
  ];

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _VoteBar extends StatelessWidget {
  const _VoteBar({
    required this.label,
    required this.pct,
    required this.isSelected,
    required this.hasVoted,
    required this.canVote,
    required this.onTap,
    required this.colors,
    required this.context,
  });

  final String label;
  final double pct;
  final bool isSelected;
  final bool hasVoted;
  final bool canVote;
  final VoidCallback? onTap;
  final AppColors colors;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    final barColor = (hasVoted && isSelected) ? colors.accent : colors.surface2;
    final textColor = (hasVoted && isSelected) ? const Color(0xFF0E0E0E) : colors.text;
    final pctDisplay = '${(pct * 100).round()}%';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background fill
              Container(color: colors.surface2),
              // Percentage fill — only visible after the user has voted
              if (hasVoted)
                FractionallySizedBox(
                  widthFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    color: isSelected ? barColor : colors.lineStrong,
                  ),
                ),
              // Label + optional percentage overlay
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTextStyles.display(12, context)
                          .copyWith(color: textColor, letterSpacing: 0.06 * 12),
                    ),
                    const Spacer(),
                    if (hasVoted)
                      Text(
                        pctDisplay,
                        style: AppTextStyles.mono(11).copyWith(color: textColor),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PredictionOption {
  const _PredictionOption({required this.pick, required this.label});
  final PredictionPick pick;
  final String label;
}
