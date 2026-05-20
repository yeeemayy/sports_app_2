import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';

/// Shows the match status as a blinking live-minute label, period label, or static text.
///
/// Blinks when the status is a live status (set [blinkingStatuses]) and the
/// [label] contains a minute marker (e.g. `"45'"`).
class MatchStatusBadge extends StatefulWidget {
  const MatchStatusBadge({
    super.key,
    required this.statusId,
    required this.label,
    this.liveColor = const Color(0xFFFF3C00),
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
      MatchStatusBadge.blinkingStatuses.contains(widget.statusId) &&
      widget.label.contains("'");

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant MatchStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  void _syncTimer() {
    if (_shouldBlink) {
      _timer ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _visible = !_visible),
      );
    } else {
      _timer?.cancel();
      _timer = null;
      if (!_visible) setState(() => _visible = true);
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

    final text =
        _shouldBlink && !_visible ? widget.label.replaceAll("'", " ") : widget.label;

    return Text(text, style: style);
  }
}
