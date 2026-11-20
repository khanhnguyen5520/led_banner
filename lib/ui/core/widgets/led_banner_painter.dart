import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../domain/models/banner_config.dart';
import 'font_helper.dart';
import 'led_grid_mask_cache.dart';

/// Deterministic LED banner renderer shared across live previews, thumbnails,
/// the full-screen display player, and offline MP4 video frame export.
class LedBannerPainter extends CustomPainter {
  const LedBannerPainter({
    required this.config,
    required this.elapsedSeconds,
    this.backgroundImage,
    this.ledMaskTile,
    this.hasLiveVideoBackground = false,
    this.forceCenterText = false,
  });

  final BannerConfig config;
  final double elapsedSeconds;
  final ui.Image? backgroundImage;
  final ui.Image? ledMaskTile;
  final bool hasLiveVideoBackground;
  final bool forceCenterText;

  /// Computes horizontal scroll cycle duration (in seconds) for MP4 auto-loop.
  static double estimateScrollCycleSeconds(
    BannerConfig config, {
    double aspectRatio = 16 / 9,
  }) {
    if (config.direction == ScrollDirection.staticText || config.speed <= 0.05) {
      return 4.0;
    }
    const refHeight = 240.0;
    final refWidth = refHeight * aspectRatio;
    final textWidth = _measureTextWidth(config, refHeight);
    final pixelsPerSecond = config.speed * refHeight * 0.65;
    if (pixelsPerSecond <= 0) return 4.0;
    final seconds = (refWidth + textWidth) / pixelsPerSecond;
    return seconds.clamp(3.0, 12.0);
  }

  static double _measureTextWidth(BannerConfig config, double height) {
    final fontSize = (height * config.fontSizeFactor).clamp(8.0, 800.0);
    final displayText = config.text.isEmpty ? ' ' : config.text;
    final tp = TextPainter(
      text: TextSpan(
        text: displayText,
        style: FontHelper.resolveFromConfig(config, fontSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    // 1. Background layer.
    _paintBackground(canvas, size);

    // 2. Subtle unlit LED matrix dots on dark backgrounds so empty regions look authentic.
    if (config.pixelLedEnabled &&
        config.backgroundType == BackgroundType.solid) {
      _paintUnlitDiodeGridHint(canvas, size);
    }

    // 3. Optional horizontal mirror transform for text and drawings.
    canvas.save();
    if (config.isMirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    // 4. Text rendering (with blink, neon glow, outline, and solid/gradient/rainbow fill).
    _paintBannerText(canvas, size);

    // 5. User freehand/shape drawings layer.
    if (config.drawings.isNotEmpty) {
      _paintDrawings(canvas, size);
    }

    canvas.restore();

    // 6. Pixel LED dot-matrix bezel mask overlay.
    if (config.pixelLedEnabled && ledMaskTile != null) {
      _paintLedMaskOverlay(canvas, size, ledMaskTile!);
    }

    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    if (hasLiveVideoBackground &&
        config.backgroundType == BackgroundType.video) {
      // VideoPlayer widget sits directly below this CustomPaint.
      if (config.backgroundDim > 0) {
        canvas.drawRect(
          bounds,
          Paint()
            ..color = Colors.black.withValues(alpha: config.backgroundDim),
        );
      }
      return;
    }

    switch (config.backgroundType) {
      case BackgroundType.solid:
        canvas.drawRect(
          bounds,
          Paint()..color = Color(config.backgroundColorValue),
        );
        break;
      case BackgroundType.image:
        if (backgroundImage != null) {
          _paintCoverImage(canvas, size, backgroundImage!);
          if (config.backgroundDim > 0) {
            canvas.drawRect(
              bounds,
              Paint()
                ..color = Colors.black.withValues(alpha: config.backgroundDim),
            );
          }
        } else {
          canvas.drawRect(
            bounds,
            Paint()..color = Color(config.backgroundColorValue),
          );
        }
        break;
      case BackgroundType.video:
        // Fallback dark studio background when live video is unavailable (e.g., thumbnail/MP4 export).
        canvas.drawRect(
          bounds,
          Paint()..color = const Color(0xFF070912),
        );
        break;
      case BackgroundType.theme:
        _paintAnimatedTheme(canvas, size, config.themePresetId, elapsedSeconds);
        if (config.backgroundDim > 0) {
          canvas.drawRect(
            bounds,
            Paint()
              ..color = Colors.black.withValues(alpha: config.backgroundDim),
          );
        }
        break;
    }
  }

  void _paintCoverImage(Canvas canvas, Size size, ui.Image image) {
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    if (imgW <= 0 || imgH <= 0) return;

    final scale = math.max(size.width / imgW, size.height / imgH);
    final scaledW = imgW * scale;
    final scaledH = imgH * scale;
    final dstRect = Rect.fromLTWH(
      (size.width - scaledW) / 2,
      (size.height - scaledH) / 2,
      scaledW,
      scaledH,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imgW, imgH),
      dstRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  void _paintUnlitDiodeGridHint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color.fromRGBO(255, 255, 255, 0.03),
    );
  }

  void _paintBannerText(Canvas canvas, Size size) {
    if (config.text.isEmpty) return;

    final double blinkOpacity;
    if (!config.blinkEnabled) {
      blinkOpacity = 1.0;
    } else if (config.blinkMode == BlinkMode.sharp) {
      final wave = math.sin(2 * math.pi * elapsedSeconds * config.blinkSpeed);
      blinkOpacity = wave >= 0 ? 1.0 : 0.07;
    } else {
      final pulse =
          0.5 + 0.5 * math.cos(2 * math.pi * elapsedSeconds * config.blinkSpeed);
      blinkOpacity = 0.14 + 0.86 * pulse;
    }

    final fontSize = (size.height * config.fontSizeFactor).clamp(10.0, 900.0);
    final baseStyle = FontHelper.resolveFromConfig(config, fontSize);

    // Measure text width using a white base style.
    final measurePainter = TextPainter(
      text: TextSpan(
        text: config.text,
        style: baseStyle.copyWith(color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final textWidth = measurePainter.width;
    final textHeight = measurePainter.height;
    final dy = (size.height - textHeight) / 2;

    final double dx;
    if (forceCenterText ||
        config.direction == ScrollDirection.staticText ||
        config.speed <= 0.0) {
      dx = (size.width - textWidth) / 2;
    } else {
      final pixelsPerSec = config.speed * size.height * 0.65;
      final cycleWidth = size.width + textWidth;
      final travel = (elapsedSeconds * pixelsPerSec) % cycleWidth;
      dx = config.direction == ScrollDirection.left
          ? size.width - travel
          : -textWidth + travel;
    }

    final offset = Offset(dx, dy);
    final scaleRatio = size.height / 240.0;

    // Pass 1: Neon Glow / Blur halo.
    if (config.glowBlur > 0.2) {
      final glowColor = _primaryGlowColor();
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.78 * blinkOpacity)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (config.glowBlur * scaleRatio).clamp(0.5, 60.0),
        );
      final glowPainter = TextPainter(
        text: TextSpan(
          text: config.text,
          style: baseStyle.copyWith(foreground: glowPaint),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      glowPainter.paint(canvas, offset);
    }

    // Pass 2: Outline / Stroke.
    if (config.outlineEnabled && config.outlineWidth > 0) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..strokeWidth = (config.outlineWidth * scaleRatio).clamp(1.0, 28.0)
        ..color =
            Color(config.outlineColorValue).withValues(alpha: blinkOpacity);
      final strokePainter = TextPainter(
        text: TextSpan(
          text: config.text,
          style: baseStyle.copyWith(foreground: strokePaint),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      strokePainter.paint(canvas, offset);
    }

    // Pass 3: Foreground Fill (Solid / Gradient / Animated Rainbow).
    final fillPaint = Paint()..style = PaintingStyle.fill;
    switch (config.textColorMode) {
      case TextColorMode.solid:
        fillPaint.color =
            Color(config.textColorValue).withValues(alpha: blinkOpacity);
        break;
      case TextColorMode.gradient:
        final start = Color(config.textColorValue).withValues(alpha: blinkOpacity);
        final end = Color(config.textGradientEndColorValue)
            .withValues(alpha: blinkOpacity);
        fillPaint.shader = ui.Gradient.linear(
          Offset(dx, dy),
          Offset(dx + math.max(textWidth, 80.0), dy + textHeight * 0.4),
          <Color>[start, end],
        );
        break;
      case TextColorMode.rainbow:
        final shift = (elapsedSeconds * 140.0) % 360.0;
        final rainbowColors = List<Color>.generate(7, (i) {
          final hue = (shift + i * 52.0) % 360.0;
          return HSVColor.fromAHSV(blinkOpacity, hue, 0.95, 1.0).toColor();
        });
        fillPaint.shader = ui.Gradient.linear(
          Offset(dx, dy),
          Offset(dx + math.max(textWidth, size.width * 0.7), dy),
          rainbowColors,
          const <double>[0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
        );
        break;
    }

    final fillPainter = TextPainter(
      text: TextSpan(
        text: config.text,
        style: baseStyle.copyWith(foreground: fillPaint),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    fillPainter.paint(canvas, offset);
  }

  Color _primaryGlowColor() {
    return switch (config.textColorMode) {
      TextColorMode.solid => Color(config.textColorValue),
      TextColorMode.gradient => Color.lerp(
          Color(config.textColorValue),
          Color(config.textGradientEndColorValue),
          0.35,
        ) ??
          Color(config.textColorValue),
      TextColorMode.rainbow =>
        HSVColor.fromAHSV(1.0, (elapsedSeconds * 120.0) % 360.0, 0.9, 1.0)
            .toColor(),
    };
  }

  void _paintDrawings(Canvas canvas, Size size) {
    final scaleRatio = size.height / 240.0;
    for (final stroke in config.drawings) {
      if (stroke.points.isEmpty) continue;
      final color = Color(stroke.colorValue);
      final width = (stroke.strokeWidth * scaleRatio).clamp(1.5, 36.0);

      if (stroke.glow) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width * 1.4
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            (width * 0.9).clamp(2.0, 24.0),
          );
        _drawStrokeGeometry(canvas, size, stroke, glowPaint);
      }

      final mainPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width;
      _drawStrokeGeometry(canvas, size, stroke, mainPaint);
    }
  }

  void _drawStrokeGeometry(
    Canvas canvas,
    Size size,
    DrawingStroke stroke,
    Paint paint,
  ) {
    Offset toPx(DrawingPoint p) => Offset(p.x * size.width, p.y * size.height);

    final pts = stroke.points;
    switch (stroke.tool) {
      case DrawingTool.freehand:
        if (pts.length == 1) {
          canvas.drawPoints(ui.PointMode.points, <Offset>[toPx(pts.first)], paint);
          return;
        }
        final path = Path()..moveTo(pts.first.x * size.width, pts.first.y * size.height);
        for (var i = 1; i < pts.length; i++) {
          final p = toPx(pts[i]);
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, paint);
        break;
      case DrawingTool.line:
        final a = toPx(pts.first);
        final b = toPx(pts.last);
        canvas.drawLine(a, b, paint);
        break;
      case DrawingTool.rectangle:
        final a = toPx(pts.first);
        final b = toPx(pts.last);
        canvas.drawRect(Rect.fromPoints(a, b), paint);
        break;
      case DrawingTool.circle:
        final a = toPx(pts.first);
        final b = toPx(pts.last);
        canvas.drawOval(Rect.fromPoints(a, b), paint);
        break;
      case DrawingTool.heart:
        final rect = Rect.fromPoints(toPx(pts.first), toPx(pts.last));
        canvas.drawPath(_buildHeartPath(rect), paint);
        break;
      case DrawingTool.star:
        final rect = Rect.fromPoints(toPx(pts.first), toPx(pts.last));
        canvas.drawPath(_buildStarPath(rect), paint);
        break;
    }
  }

  Path _buildHeartPath(Rect rect) {
    final w = rect.width;
    final h = rect.height;
    final cx = rect.center.dx;
    final top = rect.top;
    final bottom = rect.bottom;
    return Path()
      ..moveTo(cx, top + h * 0.3)
      ..cubicTo(
        cx + w * 0.5,
        top - h * 0.1,
        rect.right + w * 0.05,
        top + h * 0.45,
        cx,
        bottom,
      )
      ..cubicTo(
        rect.left - w * 0.05,
        top + h * 0.45,
        cx - w * 0.5,
        top - h * 0.1,
        cx,
        top + h * 0.3,
      )
      ..close();
  }

  Path _buildStarPath(Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final outerRx = rect.width.abs() / 2;
    final outerRy = rect.height.abs() / 2;
    final innerRx = outerRx * 0.42;
    final innerRy = outerRy * 0.42;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * (math.pi / 5);
      final isOuter = i.isEven;
      final x = cx + math.cos(angle) * (isOuter ? outerRx : innerRx);
      final y = cy + math.sin(angle) * (isOuter ? outerRy : innerRy);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _paintLedMaskOverlay(Canvas canvas, Size size, ui.Image tile) {
    final scaledPitch =
        (config.ledDotPitch * (size.height / 220.0)).clamp(3.0, 48.0);
    final scale = scaledPitch / LedGridMaskCache.tileSizePx;
    final matrix = Float64List.fromList(<double>[
      scale, 0, 0, 0,
      0, scale, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
    final shader = ui.ImageShader(
      tile,
      TileMode.repeated,
      TileMode.repeated,
      matrix,
    );
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _paintAnimatedTheme(
    Canvas canvas,
    Size size,
    ThemePresetId preset,
    double t,
  ) {
    final rect = Offset.zero & size;
    switch (preset) {
      case ThemePresetId.neonGrid:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF07061A), Color(0xFF1A0938)],
            ).createShader(rect),
        );
        final horizonY = size.height * 0.46;
        canvas.drawLine(
          Offset(0, horizonY),
          Offset(size.width, horizonY),
          Paint()
            ..color = const Color(0xFFFF2E93)
            ..strokeWidth = 2.0,
        );
        final gridPaint = Paint()
          ..color = const Color(0xFF00F5FF).withValues(alpha: 0.45)
          ..strokeWidth = 1.2;
        final cx = size.width / 2;
        for (var i = -8; i <= 8; i++) {
          canvas.drawLine(
            Offset(cx + i * (size.width * 0.05), horizonY),
            Offset(cx + i * (size.width * 0.19), size.height),
            gridPaint,
          );
        }
        final scrollOffset = (t * 0.65) % 1.0;
        for (var i = 0; i < 8; i++) {
          final p = ((i + scrollOffset) / 8.0);
          final y = horizonY + math.pow(p, 1.8) * (size.height - horizonY);
          canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
        }
        break;

      case ThemePresetId.starfield:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(0.0, -0.2),
              radius: 1.1,
              colors: <Color>[
                Color(0xFF191544),
                Color(0xFF070917),
                Color(0xFF03040A),
              ],
            ).createShader(rect),
        );
        for (var i = 0; i < 42; i++) {
          final seed = i * 37.13;
          final x = ((seed * 19.7 + t * (12 + (i % 5) * 6)) % 100) /
              100.0 *
              size.width;
          final y = ((seed * 53.3) % 100) / 100.0 * size.height;
          final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 3.0 + i));
          final r = (1.0 + (i % 3) * 0.9) * (size.height / 240.0);
          canvas.drawCircle(
            Offset(x, y),
            r.clamp(0.8, 4.5),
            Paint()..color = Colors.white.withValues(alpha: twinkle),
          );
        }
        break;

      case ThemePresetId.auroraWave:
        canvas.drawRect(rect, Paint()..color = const Color(0xFF04101A));
        final colors = <Color>[
          const Color(0xFF00FFA3),
          const Color(0xFF00E5FF),
          const Color(0xFF8B5CF6),
        ];
        for (var band = 0; band < 3; band++) {
          final path = Path();
          final baseY = size.height * (0.3 + band * 0.22);
          path.moveTo(0, size.height);
          for (var step = 0; step <= 24; step++) {
            final x = (step / 24.0) * size.width;
            final wave = math.sin(step * 0.45 + t * (1.1 + band * 0.35) + band) *
                size.height *
                0.12;
            path.lineTo(x, baseY + wave);
          }
          path.lineTo(size.width, size.height);
          path.close();
          canvas.drawPath(
            path,
            Paint()..color = colors[band].withValues(alpha: 0.22),
          );
        }
        break;

      case ThemePresetId.laserParty:
        canvas.drawRect(rect, Paint()..color = const Color(0xFF0D0417));
        final beamColors = <Color>[
          const Color(0xFFFF2E93),
          const Color(0xFF00F5FF),
          const Color(0xFFB026FF),
          const Color(0xFF39FF14),
        ];
        for (var i = 0; i < 6; i++) {
          final originX = size.width * ((i + 0.5) / 6.0);
          final sweep = math.sin(t * 2.2 + i * 1.1) * size.width * 0.38;
          final paint = Paint()
            ..color = beamColors[i % beamColors.length].withValues(alpha: 0.48)
            ..strokeWidth = (size.height * 0.035).clamp(3.0, 18.0)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
          canvas.drawLine(
            Offset(originX, 0),
            Offset(originX + sweep, size.height),
            paint,
          );
        }
        break;

      case ThemePresetId.discoSpotlights:
        canvas.drawRect(rect, Paint()..color = const Color(0xFF0B071C));
        final spotColors = <Color>[
          const Color(0xFFFFC300),
          const Color(0xFFFF2E93),
          const Color(0xFF00F5FF),
          const Color(0xFF8B5CF6),
        ];
        for (var i = 0; i < 5; i++) {
          final cx = size.width *
              (0.2 + 0.6 * (0.5 + 0.5 * math.sin(t * (0.9 + i * 0.25) + i)));
          final cy = size.height *
              (0.2 + 0.6 * (0.5 + 0.5 * math.cos(t * (0.7 + i * 0.2) + i * 2)));
          final radius = size.height * 0.42;
          canvas.drawCircle(
            Offset(cx, cy),
            radius,
            Paint()
              ..shader = RadialGradient(
                colors: <Color>[
                  spotColors[i % spotColors.length].withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius)),
          );
        }
        break;

      case ThemePresetId.birthdayConfetti:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              colors: <Color>[Color(0xFF1F0933), Color(0xFF330C2E)],
            ).createShader(rect),
        );
        final confettiColors = <Color>[
          const Color(0xFFFF2E93),
          const Color(0xFFFFE600),
          const Color(0xFF00F5FF),
          const Color(0xFF39FF14),
          const Color(0xFFFF8A00),
        ];
        for (var i = 0; i < 32; i++) {
          final x = (((i * 71.3) % 100) / 100.0) * size.width +
              math.sin(t * 2.5 + i) * size.height * 0.04;
          final y = (((i * 29.1 + t * (28 + (i % 4) * 9)) % 110) / 100.0) *
              size.height;
          final w = (size.height * 0.045).clamp(4.0, 14.0);
          canvas.save();
          canvas.translate(x, y);
          canvas.rotate(t * 3.0 + i);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.55),
            Paint()..color = confettiColors[i % confettiColors.length],
          );
          canvas.restore();
        }
        break;

      case ThemePresetId.birthdayBalloons:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF141036), Color(0xFF2B124C)],
            ).createShader(rect),
        );
        final balloonColors = <Color>[
          const Color(0xFFFF4D8D),
          const Color(0xFF38BDF8),
          const Color(0xFFFBBF24),
          const Color(0xFF34D399),
          const Color(0xFFA78BFA),
        ];
        for (var i = 0; i < 8; i++) {
          final x = size.width * ((i + 0.6) / 8.2) +
              math.sin(t * 1.4 + i) * size.width * 0.025;
          final progress = ((i * 0.19 + t * 0.18) % 1.3);
          final y = size.height * (1.15 - progress);
          final r = (size.height * 0.11).clamp(10.0, 44.0);
          final color = balloonColors[i % balloonColors.length];
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: r * 1.5, height: r * 1.9),
            Paint()..color = color.withValues(alpha: 0.72),
          );
          canvas.drawLine(
            Offset(x, y + r * 0.95),
            Offset(x, y + r * 1.6),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.45)
              ..strokeWidth = 1.2,
          );
        }
        break;

      case ThemePresetId.christmasSnow:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF061B29), Color(0xFF0B2F3A)],
            ).createShader(rect),
        );
        for (var i = 0; i < 36; i++) {
          final x = (((i * 43.7) % 100) / 100.0) * size.width +
              math.sin(t * 1.6 + i) * size.height * 0.03;
          final y = (((i * 19.3 + t * (16 + (i % 4) * 5)) % 105) / 100.0) *
              size.height;
          final r = (size.height * (0.012 + (i % 3) * 0.008)).clamp(1.5, 6.0);
          canvas.drawCircle(
            Offset(x, y),
            r,
            Paint()..color = Colors.white.withValues(alpha: 0.8),
          );
        }
        break;

      case ThemePresetId.festiveLights:
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              colors: <Color>[Color(0xFF21070C), Color(0xFF102116)],
            ).createShader(rect),
        );
        final bulbColors = <Color>[
          const Color(0xFFFF3B30),
          const Color(0xFFFFCC00),
          const Color(0xFF34C759),
          const Color(0xFF00E5FF),
        ];
        final count = 12;
        for (var i = 0; i < count; i++) {
          final x = size.width * ((i + 0.5) / count);
          final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 4.5 + i * 1.4));
          final color = bulbColors[i % bulbColors.length];
          final r = (size.height * 0.045).clamp(4.0, 18.0);
          for (final y in <double>[size.height * 0.1, size.height * 0.9]) {
            canvas.drawCircle(
              Offset(x, y),
              r * 1.8,
              Paint()
                ..color = color.withValues(alpha: 0.35 * twinkle)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
            );
            canvas.drawCircle(
              Offset(x, y),
              r * 0.75,
              Paint()..color = color.withValues(alpha: twinkle),
            );
          }
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant LedBannerPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.elapsedSeconds != elapsedSeconds ||
        oldDelegate.backgroundImage != backgroundImage ||
        oldDelegate.ledMaskTile != ledMaskTile ||
        oldDelegate.hasLiveVideoBackground != hasLiveVideoBackground ||
        oldDelegate.forceCenterText != forceCenterText;
  }
}
