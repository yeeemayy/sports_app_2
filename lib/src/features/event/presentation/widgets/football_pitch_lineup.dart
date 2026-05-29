import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/shared_widgets/sport_logo.dart';

const _homeColor = Color(0xFFFF3C00);
const _awayColor = Color(0xFF29B6F6);

class FootballPitchLineup extends StatelessWidget {
  const FootballPitchLineup({
    super.key,
    required this.homeStarters,
    required this.awayStarters,
    required this.homeSubs,
    required this.awaySubs,
    required this.homeName,
    required this.awayName,
    this.homeIcon,
    this.awayIcon,
  });

  final List<LineupPlayer> homeStarters;
  final List<LineupPlayer> awayStarters;
  final List<LineupPlayer> homeSubs;
  final List<LineupPlayer> awaySubs;
  final String homeName;
  final String awayName;
  final String? homeIcon;
  final String? awayIcon;

  static bool hasCoordinates(List<LineupPlayer> players) =>
      players.any((p) => p.x != null && p.y != null);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _TeamLegendChip(
                  name: homeName,
                  color: _homeColor,
                  icon: homeIcon,
                ),
              ),
              Expanded(
                child: _TeamLegendChip(
                  name: awayName,
                  color: _awayColor,
                  icon: awayIcon,
                  reversed: true,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 68 / 105,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _PitchPainter()),
                      ),
                      for (final p in homeStarters)
                        if (p.x != null && p.y != null)
                          _PlayerMarker(
                            player: p,
                            color: _homeColor,
                            dx: _pitchX(p.x!, w),
                            dy: _homeY(p.y!, h),
                          ),
                      for (final p in awayStarters)
                        if (p.x != null && p.y != null)
                          _PlayerMarker(
                            player: p,
                            color: _awayColor,
                            dx: _pitchX(p.x!, w),
                            dy: _awayY(p.y!, h),
                          ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (homeSubs.isNotEmpty || awaySubs.isNotEmpty)
          _SubsSection(homeSubs: homeSubs, awaySubs: awaySubs, colors: colors),
      ],
    );
  }

  static double _pitchX(int x, double w) => x / 100.0 * w;

  // Home: y=0 → bottom (own goal), y=100 → center line
  static double _homeY(int y, double h) =>
      h - (y / 100.0) * (h * 0.48) - h * 0.02;

  // Away: y=0 → top (own goal), y=100 → center line
  static double _awayY(int y, double h) => (y / 100.0) * (h * 0.48) + h * 0.02;
}

// ─── Pitch Painter ────────────────────────────────────────────────────────────

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grass base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF2A6235),
    );

    // Alternating stripes
    final stripe = Paint()..color = const Color(0xFF2F6B3A);
    const stripes = 12;
    final stripeH = h / stripes;
    for (var i = 0; i < stripes; i += 2) {
      canvas.drawRect(Rect.fromLTWH(0, i * stripeH, w, stripeH), stripe);
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dot = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Pitch border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), line);

    // Halfway line
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), line);

    // Center circle (radius = 9.15m / 68m × W)
    final ccR = 9.15 / 68.0 * w;
    canvas.drawCircle(Offset(w / 2, h / 2), ccR, line);
    canvas.drawCircle(Offset(w / 2, h / 2), 2.5, dot);

    // Penalty boxes (40.32m wide × 16.5m deep)
    final pbW = 40.32 / 68.0 * w;
    final pbH = 16.5 / 105.0 * h;
    final pbX = (w - pbW) / 2;
    canvas.drawRect(Rect.fromLTWH(pbX, 0, pbW, pbH), line);
    canvas.drawRect(Rect.fromLTWH(pbX, h - pbH, pbW, pbH), line);

    // Goal areas (18.32m wide × 5.5m deep)
    final gbW = 18.32 / 68.0 * w;
    final gbH = 5.5 / 105.0 * h;
    final gbX = (w - gbW) / 2;
    canvas.drawRect(Rect.fromLTWH(gbX, 0, gbW, gbH), line);
    canvas.drawRect(Rect.fromLTWH(gbX, h - gbH, gbW, gbH), line);

    // Goals (7.32m wide × ~2m depth visual)
    final goalW = 7.32 / 68.0 * w;
    final goalD = 2.5 / 105.0 * h;
    final goalX = (w - goalW) / 2;
    canvas.drawRect(Rect.fromLTWH(goalX, -goalD, goalW, goalD), line);
    canvas.drawRect(Rect.fromLTWH(goalX, h, goalW, goalD), line);

    // Penalty spots (11m from goal line)
    final penY = 11.0 / 105.0 * h;
    canvas.drawCircle(Offset(w / 2, penY), 2.5, dot);
    canvas.drawCircle(Offset(w / 2, h - penY), 2.5, dot);

    // Penalty arcs (D) — circle at penalty spot with 9.15m radius, clipped outside box
    final dR = 9.15 / 68.0 * w;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, pbH, w, h - pbH * 2));
    canvas.drawCircle(Offset(w / 2, penY), dR, line);
    canvas.drawCircle(Offset(w / 2, h - penY), dR, line);
    canvas.restore();

    // Corner arcs (1m radius)
    final cr = 1.0 / 68.0 * w;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: cr),
      0,
      math.pi / 2,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, 0), radius: cr),
      math.pi / 2,
      math.pi / 2,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, h), radius: cr),
      -math.pi / 2,
      math.pi / 2,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w, h), radius: cr),
      math.pi,
      math.pi / 2,
      false,
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Player Marker ────────────────────────────────────────────────────────────

class _PlayerMarker extends StatelessWidget {
  const _PlayerMarker({
    required this.player,
    required this.color,
    required this.dx,
    required this.dy,
  });

  final LineupPlayer player;
  final Color color;
  final double dx;
  final double dy;

  static const _nodeSize = 26.0;
  static const _totalW = 52.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dx - _totalW / 2,
      top: dy - _nodeSize / 2,
      width: _totalW,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _nodeSize,
                height: _nodeSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${player.shirtNumber}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              if (player.captain == 1)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB300),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _shortName(player.name),
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.1,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
                Shadow(color: Colors.black87, blurRadius: 2),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static String _shortName(String name) {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.last : name;
  }
}

// ─── Team Legend ─────────────────────────────────────────────────────────────

class _TeamLegendChip extends StatelessWidget {
  const _TeamLegendChip({
    required this.name,
    required this.color,
    this.icon,
    this.reversed = false,
  });

  final String name;
  final Color color;
  final String? icon;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final kids = <Widget>[
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      if (icon != null) ...[
        SportLogo(url: icon!, size: 18),
        const SizedBox(width: 4),
      ],
      Flexible(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: reversed
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: reversed ? kids.reversed.toList() : kids,
    );
  }
}

// ─── Substitutes ─────────────────────────────────────────────────────────────

class _SubsSection extends StatelessWidget {
  const _SubsSection({
    required this.homeSubs,
    required this.awaySubs,
    required this.colors,
  });

  final List<LineupPlayer> homeSubs;
  final List<LineupPlayer> awaySubs;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'event.football.detail.substitutes'.tr().toUpperCase(),
            style: AppTextStyles.mono(
              10,
            ).copyWith(color: colors.text3, letterSpacing: 0.14 * 10),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SubsList(
                players: homeSubs,
                color: _homeColor,
                colors: colors,
                alignEnd: false,
              ),
            ),
            Container(width: 0.5, color: colors.line),
            Expanded(
              child: _SubsList(
                players: awaySubs,
                color: _awayColor,
                colors: colors,
                alignEnd: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SubsList extends StatelessWidget {
  const _SubsList({
    required this.players,
    required this.color,
    required this.colors,
    required this.alignEnd,
  });

  final List<LineupPlayer> players;
  final Color color;
  final AppColors colors;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (final p in players)
          Padding(
            padding: EdgeInsets.fromLTRB(
              alignEnd ? 8 : 16,
              3,
              alignEnd ? 16 : 8,
              3,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: alignEnd
                  ? _rowKids(p, reversed: true)
                  : _rowKids(p, reversed: false),
            ),
          ),
      ],
    );
  }

  List<Widget> _rowKids(LineupPlayer p, {required bool reversed}) {
    final numBox = Container(
      width: 30,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        '${p.shirtNumber}',
        style: AppTextStyles.mono(
          9,
        ).copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
    final nameText = Flexible(
      child: Text(
        p.name,
        style: TextStyle(fontSize: 12, color: colors.text2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: reversed ? TextAlign.right : TextAlign.left,
      ),
    );
    final gap = const SizedBox(width: 6);

    return reversed ? [nameText, gap, numBox] : [numBox, gap, nameText];
  }
}
