import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:led_banner/domain/models/app_settings.dart';
import 'package:led_banner/domain/models/banner_config.dart';
import 'package:led_banner/domain/models/banner_history_item.dart';
import 'package:led_banner/domain/models/preset_templates.dart';
import 'package:led_banner/ui/core/widgets/led_banner_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Domain models & presets', () {
    test('BannerConfig JSON round-trip preserves all properties and drawings', () {
      const original = BannerConfig(
        text: 'CONCERT 2026 🔥',
        direction: ScrollDirection.right,
        speed: 3.4,
        fontSizeFactor: 0.82,
        letterSpacing: 4.5,
        fontId: 'bungee',
        isBold: false,
        isItalic: true,
        isMirrored: true,
        textColorMode: TextColorMode.gradient,
        textColorValue: 0xFF00F5FF,
        textGradientEndColorValue: 0xFFFF2E93,
        outlineEnabled: true,
        outlineColorValue: 0xFFFFFFFF,
        outlineWidth: 5.5,
        glowBlur: 18.0,
        blinkEnabled: true,
        blinkSpeed: 4.0,
        blinkMode: BlinkMode.pulse,
        pixelLedEnabled: false,
        ledDotShape: LedDotShape.diamond,
        ledDotPitch: 15.0,
        ledGrilleOpacity: 0.72,
        backgroundType: BackgroundType.theme,
        backgroundColorValue: 0xFF101820,
        themePresetId: ThemePresetId.auroraWave,
        backgroundImagePath: '/tmp/sample.jpg',
        backgroundVideoPath: '/tmp/sample.mp4',
        backgroundDim: 0.4,
        drawings: <DrawingStroke>[
          DrawingStroke(
            tool: DrawingTool.heart,
            points: <DrawingPoint>[
              DrawingPoint(0.2, 0.2),
              DrawingPoint(0.5, 0.6),
            ],
            colorValue: 0xFFFF007A,
            strokeWidth: 8.0,
            glow: true,
          ),
          DrawingStroke(
            tool: DrawingTool.freehand,
            points: <DrawingPoint>[
              DrawingPoint(0.1, 0.1),
              DrawingPoint(0.2, 0.3),
              DrawingPoint(0.3, 0.4),
            ],
            colorValue: 0xFF39FF14,
            strokeWidth: 4.0,
            glow: false,
          ),
        ],
        musicSourceType: MusicSourceType.builtIn,
        musicIdOrPath: 'audio/concert_pulse.wav',
        musicLabel: 'concert_pulse',
        musicVolume: 0.85,
      );

      final json = original.toJson();
      final decoded = BannerConfig.fromJson(json);

      expect(decoded, equals(original));
      expect(decoded.drawings.length, 2);
      expect(decoded.drawings.first.tool, DrawingTool.heart);
      expect(decoded.drawings.last.glow, isFalse);
    });

    test('BannerHistoryItem and AppSettings handle JSON serialization and fallbacks', () {
      final createdAt = DateTime.utc(2026, 11, 20, 10, 30);
      final item = BannerHistoryItem(
        id: 'item_1',
        config: const BannerConfig(text: 'VIP AIRPORT'),
        createdAt: createdAt,
        isPinned: true,
      );

      final roundTripItem = BannerHistoryItem.fromJson(item.toJson());
      expect(roundTripItem, equals(item));

      const settings = AppSettings(
        localeCode: 'en',
        keepScreenAwake: false,
        forceLandscape: false,
        autoSaveHistory: true,
      );
      expect(AppSettings.fromJson(settings.toJson()), equals(settings));

      final fallbackSettings = AppSettings.fromJson(
        const <String, dynamic>{'localeCode': 'fr'},
      );
      expect(fallbackSettings.localeCode, 'vi');
    });

    test('PresetTemplates.randomStyle preserves text and keeps valid contrast', () {
      const base = BannerConfig(text: 'KEEP MY MESSAGE');
      final random = Random(42);

      for (var i = 0; i < 20; i++) {
        final styled = PresetTemplates.randomStyle(base, random);
        expect(styled.text, 'KEEP MY MESSAGE');
        expect(styled.speed, inInclusiveRange(0.0, 5.0));
        expect(styled.ledDotPitch, inInclusiveRange(6.0, 22.0));
        expect(styled.glowBlur, inInclusiveRange(0.0, 28.0));

        final textLum = Color(styled.textColorValue).computeLuminance();
        final bgLum = Color(styled.backgroundColorValue).computeLuminance();
        expect(textLum - bgLum, greaterThanOrEqualTo(0.2));
      }
    });

    test('LedBannerPainter estimates scroll cycle cleanly', () {
      const staticCfg = BannerConfig(direction: ScrollDirection.staticText);
      expect(LedBannerPainter.estimateScrollCycleSeconds(staticCfg), 4.0);

      const fastCfg = BannerConfig(
        text: 'SHORT',
        direction: ScrollDirection.left,
        speed: 4.5,
      );
      expect(
        LedBannerPainter.estimateScrollCycleSeconds(fastCfg),
        inInclusiveRange(3.0, 12.0),
      );
    });
  });
}
