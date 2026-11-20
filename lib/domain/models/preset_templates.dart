import 'dart:math';

import 'package:flutter/material.dart';

import 'banner_config.dart';

/// Metadata for a built-in looping audio track bundled in `assets/audio/`.
@immutable
class BuiltInTrack {
  const BuiltInTrack({
    required this.id,
    required this.assetPath,
  });

  final String id;
  final String assetPath;
}

/// Metadata for a procedural animated theme background.
@immutable
class ThemePresetInfo {
  const ThemePresetInfo({
    required this.id,
    required this.category,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final ThemePresetId id;
  final ThemeCategory category;
  final Color primaryColor;
  final Color secondaryColor;
}

/// Ready-to-use LED banner template for quick launch or inspiration.
@immutable
class BannerTemplate {
  const BannerTemplate({
    required this.id,
    required this.config,
  });

  final String id;
  final BannerConfig config;
}

/// Catalog of built-in music tracks, animated themes, preset templates,
/// neon color swatches, and high-contrast random style generator.
abstract final class PresetTemplates {
  static const List<BuiltInTrack> builtInTracks = <BuiltInTrack>[
    BuiltInTrack(id: 'concert_pulse', assetPath: 'audio/concert_pulse.wav'),
    BuiltInTrack(id: 'birthday_chime', assetPath: 'audio/birthday_chime.wav'),
    BuiltInTrack(id: 'festive_bells', assetPath: 'audio/festive_bells.wav'),
    BuiltInTrack(id: 'neon_chill', assetPath: 'audio/neon_chill.wav'),
  ];

  static const List<ThemePresetInfo> themePresets = <ThemePresetInfo>[
    ThemePresetInfo(
      id: ThemePresetId.neonGrid,
      category: ThemeCategory.general,
      primaryColor: Color(0xFF0A122A),
      secondaryColor: Color(0xFF00F5FF),
    ),
    ThemePresetInfo(
      id: ThemePresetId.starfield,
      category: ThemeCategory.general,
      primaryColor: Color(0xFF050714),
      secondaryColor: Color(0xFF7B61FF),
    ),
    ThemePresetInfo(
      id: ThemePresetId.auroraWave,
      category: ThemeCategory.general,
      primaryColor: Color(0xFF061B26),
      secondaryColor: Color(0xFF00FFA3),
    ),
    ThemePresetInfo(
      id: ThemePresetId.laserParty,
      category: ThemeCategory.concert,
      primaryColor: Color(0xFF14071F),
      secondaryColor: Color(0xFFFF2E93),
    ),
    ThemePresetInfo(
      id: ThemePresetId.discoSpotlights,
      category: ThemeCategory.concert,
      primaryColor: Color(0xFF120B29),
      secondaryColor: Color(0xFFFFC300),
    ),
    ThemePresetInfo(
      id: ThemePresetId.birthdayConfetti,
      category: ThemeCategory.birthday,
      primaryColor: Color(0xFF210B2C),
      secondaryColor: Color(0xFFFF6EC7),
    ),
    ThemePresetInfo(
      id: ThemePresetId.birthdayBalloons,
      category: ThemeCategory.birthday,
      primaryColor: Color(0xFF181038),
      secondaryColor: Color(0xFF38BDF8),
    ),
    ThemePresetInfo(
      id: ThemePresetId.christmasSnow,
      category: ThemeCategory.holiday,
      primaryColor: Color(0xFF061E24),
      secondaryColor: Color(0xFFE2F8FF),
    ),
    ThemePresetInfo(
      id: ThemePresetId.festiveLights,
      category: ThemeCategory.holiday,
      primaryColor: Color(0xFF22090C),
      secondaryColor: Color(0xFFFFD166),
    ),
  ];

  static const List<Color> neonSwatches = <Color>[
    Color(0xFF00F5FF),
    Color(0xFFFF2E93),
    Color(0xFF39FF14),
    Color(0xFFFFE600),
    Color(0xFFFF5E00),
    Color(0xFFB026FF),
    Color(0xFFFFFFFF),
    Color(0xFFFF1E42),
    Color(0xFF00FFA3),
    Color(0xFF3B82F6),
  ];

  static const List<Color> darkBackgroundSwatches = <Color>[
    Color(0xFF05060A),
    Color(0xFF0B1021),
    Color(0xFF180824),
    Color(0xFF071A14),
    Color(0xFF22070E),
    Color(0xFF141414),
    Color(0xFF1E1B06),
    Color(0xFF041724),
  ];

  static const List<String> quickEmojis = <String>[
    '❤️',
    '🔥',
    '⭐',
    '🎉',
    '🎤',
    '👏',
    '✈️',
    '🎄',
    '🎂',
    '✨',
  ];

  static const List<String> _availableFontIds = <String>[
    'default',
    'be_vietnam_pro',
    'montserrat',
    'oswald',
    'roboto_mono',
    'jetbrains_mono',
    'pacifico',
    'playfair',
    'bungee',
    'vt323',
  ];

  static const List<BannerTemplate> templates = <BannerTemplate>[
    BannerTemplate(
      id: 'concert',
      config: BannerConfig(
        text: 'SARANGHAE ❤️ SHOWTIME! 🎤✨',
        direction: ScrollDirection.left,
        speed: 2.3,
        fontSizeFactor: 0.72,
        fontId: 'bungee',
        textColorMode: TextColorMode.gradient,
        textColorValue: 0xFFFF2E93,
        textGradientEndColorValue: 0xFF00F5FF,
        glowBlur: 14.0,
        blinkEnabled: true,
        blinkSpeed: 2.0,
        blinkMode: BlinkMode.pulse,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.circle,
        ledDotPitch: 10.0,
        backgroundType: BackgroundType.theme,
        themePresetId: ThemePresetId.laserParty,
        backgroundDim: 0.3,
        musicSourceType: MusicSourceType.builtIn,
        musicIdOrPath: 'audio/concert_pulse.wav',
        musicLabel: 'concert_pulse',
      ),
    ),
    BannerTemplate(
      id: 'airport',
      config: BannerConfig(
        text: 'WELCOME MR. NGUYEN ✈️ VIP PICKUP',
        direction: ScrollDirection.left,
        speed: 1.8,
        fontSizeFactor: 0.68,
        fontId: 'montserrat',
        textColorMode: TextColorMode.solid,
        textColorValue: 0xFFFFE600,
        outlineEnabled: true,
        outlineColorValue: 0xFF000000,
        outlineWidth: 3.0,
        glowBlur: 8.0,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.roundedSquare,
        ledDotPitch: 11.0,
        backgroundType: BackgroundType.solid,
        backgroundColorValue: 0xFF05060A,
      ),
    ),
    BannerTemplate(
      id: 'birthday',
      config: BannerConfig(
        text: 'HAPPY BIRTHDAY! 🎂🎉🥳',
        direction: ScrollDirection.left,
        speed: 2.0,
        fontSizeFactor: 0.70,
        fontId: 'pacifico',
        textColorMode: TextColorMode.rainbow,
        glowBlur: 12.0,
        blinkEnabled: true,
        blinkSpeed: 1.8,
        blinkMode: BlinkMode.pulse,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.circle,
        ledDotPitch: 11.0,
        backgroundType: BackgroundType.theme,
        themePresetId: ThemePresetId.birthdayConfetti,
        backgroundDim: 0.28,
        musicSourceType: MusicSourceType.builtIn,
        musicIdOrPath: 'audio/birthday_chime.wav',
        musicLabel: 'birthday_chime',
      ),
    ),
    BannerTemplate(
      id: 'christmas',
      config: BannerConfig(
        text: 'MERRY CHRISTMAS 🎄❄️🎁',
        direction: ScrollDirection.left,
        speed: 1.7,
        fontSizeFactor: 0.70,
        fontId: 'be_vietnam_pro',
        textColorMode: TextColorMode.gradient,
        textColorValue: 0xFFFF2A4B,
        textGradientEndColorValue: 0xFF39FF14,
        outlineEnabled: true,
        outlineColorValue: 0xFFFFFFFF,
        outlineWidth: 2.5,
        glowBlur: 10.0,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.circle,
        ledDotPitch: 10.5,
        backgroundType: BackgroundType.theme,
        themePresetId: ThemePresetId.christmasSnow,
        backgroundDim: 0.25,
        musicSourceType: MusicSourceType.builtIn,
        musicIdOrPath: 'audio/festive_bells.wav',
        musicLabel: 'festive_bells',
      ),
    ),
    BannerTemplate(
      id: 'shop_sale',
      config: BannerConfig(
        text: 'FLASH SALE 50% OFF 🔥 TODAY ONLY!',
        direction: ScrollDirection.left,
        speed: 2.6,
        fontSizeFactor: 0.74,
        fontId: 'oswald',
        textColorMode: TextColorMode.solid,
        textColorValue: 0xFF39FF14,
        outlineEnabled: true,
        outlineColorValue: 0xFFFF1E42,
        outlineWidth: 3.5,
        glowBlur: 12.0,
        blinkEnabled: true,
        blinkSpeed: 3.2,
        blinkMode: BlinkMode.sharp,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.square,
        ledDotPitch: 11.0,
        backgroundType: BackgroundType.solid,
        backgroundColorValue: 0xFF0A0A0E,
      ),
    ),
    BannerTemplate(
      id: 'party',
      config: BannerConfig(
        text: 'LET’S PARTY TONIGHT 🪩⚡🔥',
        direction: ScrollDirection.left,
        speed: 2.8,
        fontSizeFactor: 0.72,
        fontId: 'vt323',
        textColorMode: TextColorMode.gradient,
        textColorValue: 0xFF00F5FF,
        textGradientEndColorValue: 0xFFB026FF,
        glowBlur: 16.0,
        blinkEnabled: true,
        blinkSpeed: 2.6,
        blinkMode: BlinkMode.sharp,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.diamond,
        ledDotPitch: 12.0,
        backgroundType: BackgroundType.theme,
        themePresetId: ThemePresetId.discoSpotlights,
        backgroundDim: 0.25,
        musicSourceType: MusicSourceType.builtIn,
        musicIdOrPath: 'audio/neon_chill.wav',
        musicLabel: 'neon_chill',
      ),
    ),
    BannerTemplate(
      id: 'taxi',
      config: BannerConfig(
        text: 'TAXI PLEASE! 👋🚕',
        direction: ScrollDirection.staticText,
        speed: 0.0,
        fontSizeFactor: 0.75,
        fontId: 'be_vietnam_pro',
        textColorMode: TextColorMode.solid,
        textColorValue: 0xFFFFE600,
        glowBlur: 14.0,
        blinkEnabled: true,
        blinkSpeed: 3.5,
        blinkMode: BlinkMode.sharp,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.circle,
        ledDotPitch: 10.0,
        backgroundType: BackgroundType.solid,
        backgroundColorValue: 0xFF05060A,
      ),
    ),
    BannerTemplate(
      id: 'love',
      config: BannerConfig(
        text: 'I LOVE YOU SO MUCH ❤️✨',
        direction: ScrollDirection.left,
        speed: 1.9,
        fontSizeFactor: 0.70,
        fontId: 'playfair',
        isItalic: true,
        textColorMode: TextColorMode.gradient,
        textColorValue: 0xFFFF2E93,
        textGradientEndColorValue: 0xFFFF9EBB,
        glowBlur: 15.0,
        pixelLedEnabled: true,
        ledDotShape: LedDotShape.circle,
        ledDotPitch: 10.0,
        backgroundType: BackgroundType.theme,
        themePresetId: ThemePresetId.starfield,
        backgroundDim: 0.2,
      ),
    ),
  ];

  /// Generates a visually vibrant, high-contrast random style while preserving text.
  static BannerConfig randomStyle(BannerConfig current, Random random) {
    final textColor = neonSwatches[random.nextInt(neonSwatches.length)];
    Color gradientEnd = neonSwatches[random.nextInt(neonSwatches.length)];
    if (gradientEnd.toARGB32() == textColor.toARGB32()) {
      gradientEnd = neonSwatches[(neonSwatches.indexOf(textColor) + 3) %
          neonSwatches.length];
    }

    final bgColor =
        darkBackgroundSwatches[random.nextInt(darkBackgroundSwatches.length)];

    // Guarantee high contrast between textColor and dark background.
    final Color safeTextColor =
        textColor.computeLuminance() - bgColor.computeLuminance() >= 0.25
            ? textColor
            : const Color(0xFF00F5FF);

    final useTheme = random.nextDouble() < 0.45;
    final colorModes = TextColorMode.values;
    final dotShapes = LedDotShape.values;
    final themes = ThemePresetId.values;
    final outlineEnabled = random.nextBool();
    final blinkEnabled = random.nextDouble() < 0.4;
    final pixelLedEnabled = random.nextDouble() < 0.82;

    return current.copyWith(
      fontId: _availableFontIds[random.nextInt(_availableFontIds.length)],
      isBold: random.nextDouble() < 0.85,
      isItalic: random.nextDouble() < 0.2,
      textColorMode: colorModes[random.nextInt(colorModes.length)],
      textColorValue: safeTextColor.toARGB32(),
      textGradientEndColorValue: gradientEnd.toARGB32(),
      outlineEnabled: outlineEnabled,
      outlineColorValue: gradientEnd.toARGB32(),
      outlineWidth: 2.0 + random.nextInt(4).toDouble(),
      glowBlur: (4 + random.nextInt(15)).toDouble(),
      blinkEnabled: blinkEnabled,
      blinkSpeed: 1.5 + random.nextDouble() * 2.5,
      blinkMode: random.nextBool() ? BlinkMode.sharp : BlinkMode.pulse,
      pixelLedEnabled: pixelLedEnabled,
      ledDotShape: dotShapes[random.nextInt(dotShapes.length)],
      ledDotPitch: 9.0 + random.nextInt(6).toDouble(),
      backgroundType: useTheme ? BackgroundType.theme : BackgroundType.solid,
      backgroundColorValue: bgColor.toARGB32(),
      themePresetId: themes[random.nextInt(themes.length)],
      backgroundDim: 0.25,
    );
  }
}
