import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../domain/models/banner_config.dart';

/// Generates and caches crisp repeatable LED bezel mask tiles (`ui.Image`).
///
/// Each tile draws a dark LED matrix grille and punches a transparent aperture
/// in the center matching [LedDotShape] so the glowing text/background shines
/// through like individual physical LED bulbs.
class LedGridMaskCache {
  LedGridMaskCache._();

  static const int tileSizePx = 48;
  static const int _maxCacheEntries = 16;

  static final LinkedHashMap<String, ui.Image> _cache =
      LinkedHashMap<String, ui.Image>();

  static String _key(LedDotShape shape, double grilleOpacity) {
    final quantizedOpacity = (grilleOpacity * 100).round();
    return '${shape.name}_$quantizedOpacity';
  }

  /// Returns a cached tile synchronously if present, or generates & caches it.
  static ui.Image getOrCreateTile({
    required LedDotShape shape,
    required double grilleOpacity,
  }) {
    final key = _key(shape, grilleOpacity);
    final existing = _cache.remove(key);
    if (existing != null) {
      _cache[key] = existing;
      return existing;
    }

    final created = generateTile(shape: shape, grilleOpacity: grilleOpacity);
    _cache[key] = created;

    while (_cache.length > _maxCacheEntries) {
      final oldestKey = _cache.keys.first;
      final removed = _cache.remove(oldestKey);
      removed?.dispose();
    }

    return created;
  }

  /// Generates a standalone `tileSizePx x tileSizePx` LED mask tile.
  ///
  /// Callers creating tiles outside the cache (e.g. offscreen export) should
  /// dispose the returned [ui.Image] when done.
  static ui.Image generateTile({
    required LedDotShape shape,
    required double grilleOpacity,
  }) {
    final size = tileSizePx.toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

    // Outer dark LED board grille.
    final grillePaint = Paint()
      ..color = Color.fromRGBO(5, 6, 10, grilleOpacity.clamp(0.2, 1.0));
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), grillePaint);

    // Punch transparent aperture for the LED bulb.
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..isAntiAlias = true;

    final center = Offset(size / 2, size / 2);
    final apertureRadius = size * 0.36;

    switch (shape) {
      case LedDotShape.circle:
        canvas.drawCircle(center, apertureRadius, clearPaint);
        break;
      case LedDotShape.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: apertureRadius * 1.9,
            height: apertureRadius * 1.9,
          ),
          clearPaint,
        );
        break;
      case LedDotShape.roundedSquare:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: apertureRadius * 1.95,
              height: apertureRadius * 1.95,
            ),
            Radius.circular(size * 0.14),
          ),
          clearPaint,
        );
        break;
      case LedDotShape.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - apertureRadius * 1.15)
          ..lineTo(center.dx + apertureRadius * 1.15, center.dy)
          ..lineTo(center.dx, center.dy + apertureRadius * 1.15)
          ..lineTo(center.dx - apertureRadius * 1.15, center.dy)
          ..close();
        canvas.drawPath(path, clearPaint);
        break;
    }

    // Subtle specular diode ring inside the bezel edge for realism.
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color.fromRGBO(255, 255, 255, 0.08)
      ..isAntiAlias = true;
    switch (shape) {
      case LedDotShape.circle:
        canvas.drawCircle(center, math.max(1, apertureRadius - 0.8), rimPaint);
        break;
      case LedDotShape.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: apertureRadius * 1.9,
            height: apertureRadius * 1.9,
          ),
          rimPaint,
        );
        break;
      case LedDotShape.roundedSquare:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: apertureRadius * 1.95,
              height: apertureRadius * 1.95,
            ),
            Radius.circular(size * 0.14),
          ),
          rimPaint,
        );
        break;
      case LedDotShape.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - apertureRadius * 1.15)
          ..lineTo(center.dx + apertureRadius * 1.15, center.dy)
          ..lineTo(center.dx, center.dy + apertureRadius * 1.15)
          ..lineTo(center.dx - apertureRadius * 1.15, center.dy)
          ..close();
        canvas.drawPath(path, rimPaint);
        break;
    }

    final picture = recorder.endRecording();
    try {
      return picture.toImageSync(tileSizePx, tileSizePx);
    } finally {
      picture.dispose();
    }
  }
}
