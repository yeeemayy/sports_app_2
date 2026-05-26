import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Returns a deterministic color seeded from an entity [id].
/// Used as an instant fallback before a logo palette resolves.
Color seededColorFromId(
  String id, {
  double saturation = 0.55,
  double lightness = 0.38,
}) {
  final seed = id.codeUnits.fold(0, (a, b) => a ^ b);
  final hue = (seed * 137.5) % 360;
  return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
}

/// Returns [base] lightened by [delta] — used to build gradient end colors.
Color lightenColor(Color base, {double delta = 0.14}) {
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
}

/// Mixin for [State] subclasses that need a dominant color extracted from a
/// logo URL asynchronously.
///
/// Usage:
/// ```dart
/// class _MyState extends State<MyWidget> with LogoColorMixin<MyWidget> {
///   @override
///   void initState() {
///     super.initState();
///     extractLogoColor(widget.logoUrl);
///   }
/// }
/// ```
///
/// Read [logoColor] in [build] — it is `null` until the palette resolves, so
/// always supply a fallback (e.g. [seededColorFromId]).
mixin LogoColorMixin<T extends StatefulWidget> on State<T> {
  Color? _logoColor;

  /// The extracted dominant color, or `null` while still loading.
  Color? get logoColor => _logoColor;

  /// Kicks off palette extraction from [logoUrl].
  /// Calls [setState] once the color is ready; no-ops on empty / null URLs.
  Future<void> extractLogoColor(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(logoUrl),
        size: const Size(64, 64),
        maximumColorCount: 8,
      );
      final color = palette.darkVibrantColor?.color ??
          palette.vibrantColor?.color ??
          palette.darkMutedColor?.color ??
          palette.dominantColor?.color;
      if (color != null && mounted) {
        setState(() => _logoColor = color);
      }
    } catch (_) {
      // Keep fallback silently.
    }
  }
}
