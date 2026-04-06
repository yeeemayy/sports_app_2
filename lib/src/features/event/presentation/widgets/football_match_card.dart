import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';

class FootballMatchCard extends StatelessWidget {
  const FootballMatchCard({super.key, required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final hasHtScore = match.htHomeScore != null && match.htAwayScore != null;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.footballMatchDetailPath(match.id)),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League header row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _LeagueLogo(url: match.leagueLogo),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            match.leagueName,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 35,
                    child: Center(
                      child: MatchStatusBadge(statusId: match.statusId, label: match.statusLabel),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        match.matchTimeSim,
                        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Match body — horizontal layout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home team
                  Expanded(
                    child: Row(
                      children: [
                        _TeamLogo(url: match.homeLogo),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            match.homeName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score / status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _ScoreDisplay(
                      homeScore: match.homeScore,
                      awayScore: match.awayScore,
                      statusId: match.statusId,
                    ),
                  ),
                  // Away team
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            match.awayName,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _TeamLogo(url: match.awayLogo),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Footer row — HT score
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 8, 8),
              child: Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: match.statusId > 3 && match.statusId!=8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasHtScore)
                      Text(
                        '${'event.football.ht'.tr()} ${match.htHomeScore}-${match.htAwayScore}',
                        style: context.textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }
}

/// Shows the match status in the header: blinking live minute, period label, or a static status.
class MatchStatusBadge extends StatefulWidget {
  const MatchStatusBadge({
    super.key,
    required this.statusId,
    required this.label,
    this.liveColor = Colors.pink,
    this.staticColor,
  });

  final int statusId;
  final String label;
  final Color liveColor;
  final Color? staticColor;

  static const blinkingStatuses = {2, 4, 5, 6, 7};

  @override
  State<MatchStatusBadge> createState() => _MatchStatusBadgeState();
}

class _MatchStatusBadgeState extends State<MatchStatusBadge> {
  bool _visible = true;
  Timer? _timer;

  bool get _shouldBlink =>
      MatchStatusBadge.blinkingStatuses.contains(widget.statusId) && widget.label.contains("'");

  @override
  void initState() {
    super.initState();
    _setupTimer();
  }

  @override
  void didUpdateWidget(covariant MatchStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupTimer();
  }

  void _setupTimer() {
    _timer?.cancel();

    if (_shouldBlink) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _visible = !_visible),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelSmall?.copyWith(
      color: MatchStatusBadge.blinkingStatuses.contains(widget.statusId)
          ? widget.liveColor
          : (widget.staticColor ?? Colors.grey.shade600),
      fontWeight: FontWeight.w600,
    );

    final text = _shouldBlink && !_visible ? widget.label.replaceAll("'", " ") : widget.label;

    return Text(text, style: style);
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.homeScore, required this.awayScore, required this.statusId});

  final String homeScore;
  final String awayScore;
  final int statusId;

  static const _liveStatuses = {2, 3, 4, 5, 6, 7};
  static const _noScoreStatuses = {0, 1, 13};

  @override
  Widget build(BuildContext context) {
    if (_noScoreStatuses.contains(statusId)) {
      return Text(
        '-',
        style: context.textTheme.titleSmall?.copyWith(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final scoreColor = _liveStatuses.contains(statusId) ? Colors.pink : Colors.black87;
    return RichText(
      text: TextSpan(
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: scoreColor,
        ),
        children: [
          TextSpan(text: homeScore),
          TextSpan(
            text: ' - ',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          TextSpan(text: awayScore),
        ],
      ),
    );
  }
}

class _LeagueLogo extends StatelessWidget {
  const _LeagueLogo({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox(width: 16, height: 16);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 16,
        height: 16,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => const SizedBox(width: 16, height: 16),
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: url.isEmpty
          ? AvatarFallback(size: 24, iconSize: 12)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, _) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: const AvatarFallback(size: 24, iconSize: 12),
              ),
              errorBuilder: (_, _, _) => AvatarFallback(size: 24, iconSize: 12),
            ),
    );
  }
}
