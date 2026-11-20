import 'package:flutter/foundation.dart';

/// Scrolling direction for the LED banner text.
enum ScrollDirection { left, right, staticText }

/// Fill mode for the LED banner text.
enum TextColorMode { solid, gradient, rainbow }

/// Blinking waveform style.
enum BlinkMode { sharp, pulse }

/// Shape of individual LED diode cells when Pixel LED mode is enabled.
enum LedDotShape { circle, square, roundedSquare, diamond }

/// Background layer type behind the LED text.
enum BackgroundType { solid, theme, image, video }

/// Theme category filter shown in the Background tab.
enum ThemeCategory { general, concert, birthday, holiday }

/// Built-in animated procedural background themes.
enum ThemePresetId {
  neonGrid,
  starfield,
  auroraWave,
  laserParty,
  discoSpotlights,
  birthdayConfetti,
  birthdayBalloons,
  christmasSnow,
  festiveLights,
}

/// Supported freehand and geometric drawing tools.
enum DrawingTool { freehand, line, rectangle, circle, heart, star }

/// Source of optional background music played during full-screen LED display.
enum MusicSourceType { none, builtIn, file }

/// Normalized coordinate (0.0 .. 1.0) on the banner canvas.
@immutable
class DrawingPoint {
  const DrawingPoint(this.x, this.y);

  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    return DrawingPoint(
      (json['x'] as num?)?.toDouble() ?? 0.5,
      (json['y'] as num?)?.toDouble() ?? 0.5,
    );
  }

  final double x;
  final double y;

  Map<String, dynamic> toJson() => <String, dynamic>{'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// A single freehand stroke or shape drawn onto the banner overlay.
@immutable
class DrawingStroke {
  const DrawingStroke({
    required this.tool,
    required this.points,
    required this.colorValue,
    required this.strokeWidth,
    this.glow = true,
  });

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? const <dynamic>[];
    return DrawingStroke(
      tool: _enumByName(
        DrawingTool.values,
        json['tool'] as String?,
        DrawingTool.freehand,
      ),
      points: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(DrawingPoint.fromJson)
          .toList(growable: false),
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF00F5FF,
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 6.0,
      glow: json['glow'] as bool? ?? true,
    );
  }

  final DrawingTool tool;
  final List<DrawingPoint> points;
  final int colorValue;
  final double strokeWidth;
  final bool glow;

  DrawingStroke copyWith({
    DrawingTool? tool,
    List<DrawingPoint>? points,
    int? colorValue,
    double? strokeWidth,
    bool? glow,
  }) {
    return DrawingStroke(
      tool: tool ?? this.tool,
      points: points ?? this.points,
      colorValue: colorValue ?? this.colorValue,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      glow: glow ?? this.glow,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tool': tool.name,
    'points': points.map((p) => p.toJson()).toList(growable: false),
    'colorValue': colorValue,
    'strokeWidth': strokeWidth,
    'glow': glow,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingStroke &&
          runtimeType == other.runtimeType &&
          tool == other.tool &&
          listEquals(points, other.points) &&
          colorValue == other.colorValue &&
          strokeWidth == other.strokeWidth &&
          glow == other.glow;

  @override
  int get hashCode => Object.hash(
    tool,
    Object.hashAll(points),
    colorValue,
    strokeWidth,
    glow,
  );
}

/// Complete immutable configuration of an LED banner sign.
@immutable
class BannerConfig {
  const BannerConfig({
    this.text = 'HELLO LED ✨',
    this.direction = ScrollDirection.left,
    this.speed = 2.0,
    this.fontSizeFactor = 0.68,
    this.letterSpacing = 2.0,
    this.fontId = 'be_vietnam_pro',
    this.isBold = true,
    this.isItalic = false,
    this.isMirrored = false,
    this.textColorMode = TextColorMode.solid,
    this.textColorValue = 0xFF00F5FF,
    this.textGradientEndColorValue = 0xFFFF2E93,
    this.outlineEnabled = false,
    this.outlineColorValue = 0xFFFF007A,
    this.outlineWidth = 4.0,
    this.glowBlur = 10.0,
    this.blinkEnabled = false,
    this.blinkSpeed = 2.5,
    this.blinkMode = BlinkMode.sharp,
    this.pixelLedEnabled = true,
    this.ledDotShape = LedDotShape.circle,
    this.ledDotPitch = 11.0,
    this.ledGrilleOpacity = 0.88,
    this.backgroundType = BackgroundType.solid,
    this.backgroundColorValue = 0xFF05060A,
    this.themePresetId = ThemePresetId.neonGrid,
    this.backgroundImagePath,
    this.backgroundVideoPath,
    this.backgroundDim = 0.25,
    this.drawings = const <DrawingStroke>[],
    this.musicSourceType = MusicSourceType.none,
    this.musicIdOrPath,
    this.musicLabel,
    this.musicVolume = 0.7,
  });

  factory BannerConfig.fromJson(Map<String, dynamic> json) {
    final rawDrawings = json['drawings'] as List<dynamic>? ?? const <dynamic>[];
    return BannerConfig(
      text: json['text'] as String? ?? 'HELLO LED ✨',
      direction: _enumByName(
        ScrollDirection.values,
        json['direction'] as String?,
        ScrollDirection.left,
      ),
      speed: ((json['speed'] as num?)?.toDouble() ?? 2.0).clamp(0.0, 5.0),
      fontSizeFactor: ((json['fontSizeFactor'] as num?)?.toDouble() ?? 0.68)
          .clamp(0.25, 0.95),
      letterSpacing: ((json['letterSpacing'] as num?)?.toDouble() ?? 2.0)
          .clamp(-2.0, 16.0),
      fontId: json['fontId'] as String? ?? 'be_vietnam_pro',
      isBold: json['isBold'] as bool? ?? true,
      isItalic: json['isItalic'] as bool? ?? false,
      isMirrored: json['isMirrored'] as bool? ?? false,
      textColorMode: _enumByName(
        TextColorMode.values,
        json['textColorMode'] as String?,
        TextColorMode.solid,
      ),
      textColorValue: (json['textColorValue'] as num?)?.toInt() ?? 0xFF00F5FF,
      textGradientEndColorValue:
          (json['textGradientEndColorValue'] as num?)?.toInt() ?? 0xFFFF2E93,
      outlineEnabled: json['outlineEnabled'] as bool? ?? false,
      outlineColorValue:
          (json['outlineColorValue'] as num?)?.toInt() ?? 0xFFFF007A,
      outlineWidth: ((json['outlineWidth'] as num?)?.toDouble() ?? 4.0)
          .clamp(1.0, 12.0),
      glowBlur: ((json['glowBlur'] as num?)?.toDouble() ?? 10.0)
          .clamp(0.0, 28.0),
      blinkEnabled: json['blinkEnabled'] as bool? ?? false,
      blinkSpeed: ((json['blinkSpeed'] as num?)?.toDouble() ?? 2.5)
          .clamp(1.0, 6.0),
      blinkMode: _enumByName(
        BlinkMode.values,
        json['blinkMode'] as String?,
        BlinkMode.sharp,
      ),
      pixelLedEnabled: json['pixelLedEnabled'] as bool? ?? true,
      ledDotShape: _enumByName(
        LedDotShape.values,
        json['ledDotShape'] as String?,
        LedDotShape.circle,
      ),
      ledDotPitch: ((json['ledDotPitch'] as num?)?.toDouble() ?? 11.0)
          .clamp(6.0, 22.0),
      ledGrilleOpacity:
          ((json['ledGrilleOpacity'] as num?)?.toDouble() ?? 0.88)
              .clamp(0.35, 1.0),
      backgroundType: _enumByName(
        BackgroundType.values,
        json['backgroundType'] as String?,
        BackgroundType.solid,
      ),
      backgroundColorValue:
          (json['backgroundColorValue'] as num?)?.toInt() ?? 0xFF05060A,
      themePresetId: _enumByName(
        ThemePresetId.values,
        json['themePresetId'] as String?,
        ThemePresetId.neonGrid,
      ),
      backgroundImagePath: json['backgroundImagePath'] as String?,
      backgroundVideoPath: json['backgroundVideoPath'] as String?,
      backgroundDim: ((json['backgroundDim'] as num?)?.toDouble() ?? 0.25)
          .clamp(0.0, 0.85),
      drawings: rawDrawings
          .whereType<Map<String, dynamic>>()
          .map(DrawingStroke.fromJson)
          .toList(growable: false),
      musicSourceType: _enumByName(
        MusicSourceType.values,
        json['musicSourceType'] as String?,
        MusicSourceType.none,
      ),
      musicIdOrPath: json['musicIdOrPath'] as String?,
      musicLabel: json['musicLabel'] as String?,
      musicVolume: ((json['musicVolume'] as num?)?.toDouble() ?? 0.7)
          .clamp(0.0, 1.0),
    );
  }

  final String text;
  final ScrollDirection direction;
  final double speed;
  final double fontSizeFactor;
  final double letterSpacing;
  final String fontId;
  final bool isBold;
  final bool isItalic;
  final bool isMirrored;
  final TextColorMode textColorMode;
  final int textColorValue;
  final int textGradientEndColorValue;
  final bool outlineEnabled;
  final int outlineColorValue;
  final double outlineWidth;
  final double glowBlur;
  final bool blinkEnabled;
  final double blinkSpeed;
  final BlinkMode blinkMode;
  final bool pixelLedEnabled;
  final LedDotShape ledDotShape;
  final double ledDotPitch;
  final double ledGrilleOpacity;
  final BackgroundType backgroundType;
  final int backgroundColorValue;
  final ThemePresetId themePresetId;
  final String? backgroundImagePath;
  final String? backgroundVideoPath;
  final double backgroundDim;
  final List<DrawingStroke> drawings;
  final MusicSourceType musicSourceType;
  final String? musicIdOrPath;
  final String? musicLabel;
  final double musicVolume;

  BannerConfig copyWith({
    String? text,
    ScrollDirection? direction,
    double? speed,
    double? fontSizeFactor,
    double? letterSpacing,
    String? fontId,
    bool? isBold,
    bool? isItalic,
    bool? isMirrored,
    TextColorMode? textColorMode,
    int? textColorValue,
    int? textGradientEndColorValue,
    bool? outlineEnabled,
    int? outlineColorValue,
    double? outlineWidth,
    double? glowBlur,
    bool? blinkEnabled,
    double? blinkSpeed,
    BlinkMode? blinkMode,
    bool? pixelLedEnabled,
    LedDotShape? ledDotShape,
    double? ledDotPitch,
    double? ledGrilleOpacity,
    BackgroundType? backgroundType,
    int? backgroundColorValue,
    ThemePresetId? themePresetId,
    String? backgroundImagePath,
    bool clearBackgroundImagePath = false,
    String? backgroundVideoPath,
    bool clearBackgroundVideoPath = false,
    double? backgroundDim,
    List<DrawingStroke>? drawings,
    MusicSourceType? musicSourceType,
    String? musicIdOrPath,
    bool clearMusicIdOrPath = false,
    String? musicLabel,
    bool clearMusicLabel = false,
    double? musicVolume,
  }) {
    return BannerConfig(
      text: text ?? this.text,
      direction: direction ?? this.direction,
      speed: speed ?? this.speed,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontId: fontId ?? this.fontId,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isMirrored: isMirrored ?? this.isMirrored,
      textColorMode: textColorMode ?? this.textColorMode,
      textColorValue: textColorValue ?? this.textColorValue,
      textGradientEndColorValue:
          textGradientEndColorValue ?? this.textGradientEndColorValue,
      outlineEnabled: outlineEnabled ?? this.outlineEnabled,
      outlineColorValue: outlineColorValue ?? this.outlineColorValue,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      glowBlur: glowBlur ?? this.glowBlur,
      blinkEnabled: blinkEnabled ?? this.blinkEnabled,
      blinkSpeed: blinkSpeed ?? this.blinkSpeed,
      blinkMode: blinkMode ?? this.blinkMode,
      pixelLedEnabled: pixelLedEnabled ?? this.pixelLedEnabled,
      ledDotShape: ledDotShape ?? this.ledDotShape,
      ledDotPitch: ledDotPitch ?? this.ledDotPitch,
      ledGrilleOpacity: ledGrilleOpacity ?? this.ledGrilleOpacity,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      themePresetId: themePresetId ?? this.themePresetId,
      backgroundImagePath: clearBackgroundImagePath
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      backgroundVideoPath: clearBackgroundVideoPath
          ? null
          : (backgroundVideoPath ?? this.backgroundVideoPath),
      backgroundDim: backgroundDim ?? this.backgroundDim,
      drawings: drawings ?? this.drawings,
      musicSourceType: musicSourceType ?? this.musicSourceType,
      musicIdOrPath: clearMusicIdOrPath
          ? null
          : (musicIdOrPath ?? this.musicIdOrPath),
      musicLabel: clearMusicLabel ? null : (musicLabel ?? this.musicLabel),
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text': text,
    'direction': direction.name,
    'speed': speed,
    'fontSizeFactor': fontSizeFactor,
    'letterSpacing': letterSpacing,
    'fontId': fontId,
    'isBold': isBold,
    'isItalic': isItalic,
    'isMirrored': isMirrored,
    'textColorMode': textColorMode.name,
    'textColorValue': textColorValue,
    'textGradientEndColorValue': textGradientEndColorValue,
    'outlineEnabled': outlineEnabled,
    'outlineColorValue': outlineColorValue,
    'outlineWidth': outlineWidth,
    'glowBlur': glowBlur,
    'blinkEnabled': blinkEnabled,
    'blinkSpeed': blinkSpeed,
    'blinkMode': blinkMode.name,
    'pixelLedEnabled': pixelLedEnabled,
    'ledDotShape': ledDotShape.name,
    'ledDotPitch': ledDotPitch,
    'ledGrilleOpacity': ledGrilleOpacity,
    'backgroundType': backgroundType.name,
    'backgroundColorValue': backgroundColorValue,
    'themePresetId': themePresetId.name,
    'backgroundImagePath': backgroundImagePath,
    'backgroundVideoPath': backgroundVideoPath,
    'backgroundDim': backgroundDim,
    'drawings': drawings.map((d) => d.toJson()).toList(growable: false),
    'musicSourceType': musicSourceType.name,
    'musicIdOrPath': musicIdOrPath,
    'musicLabel': musicLabel,
    'musicVolume': musicVolume,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerConfig &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          direction == other.direction &&
          speed == other.speed &&
          fontSizeFactor == other.fontSizeFactor &&
          letterSpacing == other.letterSpacing &&
          fontId == other.fontId &&
          isBold == other.isBold &&
          isItalic == other.isItalic &&
          isMirrored == other.isMirrored &&
          textColorMode == other.textColorMode &&
          textColorValue == other.textColorValue &&
          textGradientEndColorValue == other.textGradientEndColorValue &&
          outlineEnabled == other.outlineEnabled &&
          outlineColorValue == other.outlineColorValue &&
          outlineWidth == other.outlineWidth &&
          glowBlur == other.glowBlur &&
          blinkEnabled == other.blinkEnabled &&
          blinkSpeed == other.blinkSpeed &&
          blinkMode == other.blinkMode &&
          pixelLedEnabled == other.pixelLedEnabled &&
          ledDotShape == other.ledDotShape &&
          ledDotPitch == other.ledDotPitch &&
          ledGrilleOpacity == other.ledGrilleOpacity &&
          backgroundType == other.backgroundType &&
          backgroundColorValue == other.backgroundColorValue &&
          themePresetId == other.themePresetId &&
          backgroundImagePath == other.backgroundImagePath &&
          backgroundVideoPath == other.backgroundVideoPath &&
          backgroundDim == other.backgroundDim &&
          listEquals(drawings, other.drawings) &&
          musicSourceType == other.musicSourceType &&
          musicIdOrPath == other.musicIdOrPath &&
          musicLabel == other.musicLabel &&
          musicVolume == other.musicVolume;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    text,
    direction,
    speed,
    fontSizeFactor,
    letterSpacing,
    fontId,
    isBold,
    isItalic,
    isMirrored,
    textColorMode,
    textColorValue,
    textGradientEndColorValue,
    outlineEnabled,
    outlineColorValue,
    outlineWidth,
    glowBlur,
    blinkEnabled,
    blinkSpeed,
    blinkMode,
    pixelLedEnabled,
    ledDotShape,
    ledDotPitch,
    ledGrilleOpacity,
    backgroundType,
    backgroundColorValue,
    themePresetId,
    backgroundImagePath,
    backgroundVideoPath,
    backgroundDim,
    Object.hashAll(drawings),
    musicSourceType,
    musicIdOrPath,
    musicLabel,
    musicVolume,
  ]);
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
