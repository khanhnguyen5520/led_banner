// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LED Banner';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get apply => 'Apply';

  @override
  String get done => 'Done';

  @override
  String get clear => 'Clear';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get reset => 'Reset';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get historyTooltip => 'History & Templates';

  @override
  String get randomizeTooltip => 'Random Style';

  @override
  String get exportTooltip => 'Export MP4';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get playFullScreen => 'Play Full Screen';

  @override
  String get messageHint => 'Enter your LED message...';

  @override
  String get clearText => 'Clear text';

  @override
  String get drawShortcut => 'Draw';

  @override
  String get randomStyleApplied => 'Random LED style applied!';

  @override
  String get tabText => 'Text';

  @override
  String get tabEffects => 'Effects';

  @override
  String get tabLedStyle => 'LED Dots';

  @override
  String get tabBackground => 'Background';

  @override
  String get tabMediaDraw => 'Music & Draw';

  @override
  String get scrollDirection => 'Scroll Direction';

  @override
  String get dirLeft => 'Left';

  @override
  String get dirStatic => 'Static';

  @override
  String get dirRight => 'Right';

  @override
  String get scrollSpeed => 'Scroll Speed';

  @override
  String get fontSize => 'Font Size';

  @override
  String get letterSpacing => 'Letter Spacing';

  @override
  String get textStyle => 'Text Style';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get mirror => 'Mirror';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get fontDefault => 'System';

  @override
  String get colorMode => 'Text Color Mode';

  @override
  String get modeSolid => 'Solid';

  @override
  String get modeGradient => 'Gradient';

  @override
  String get modeRainbow => 'Rainbow';

  @override
  String get textColor => 'Text Color';

  @override
  String get gradientEndColor => 'Gradient End Color';

  @override
  String get neonGlow => 'Neon Glow / Blur';

  @override
  String get textOutline => 'Text Outline';

  @override
  String get outlineColor => 'Outline Color';

  @override
  String get outlineWidth => 'Outline Thickness';

  @override
  String get blinkEffect => 'Blink Effect';

  @override
  String get blinkMode => 'Blink Style';

  @override
  String get blinkSharp => 'Sharp Flash';

  @override
  String get blinkPulse => 'Smooth Pulse';

  @override
  String get blinkSpeed => 'Blink Speed';

  @override
  String hzUnit(String value) {
    return '$value Hz';
  }

  @override
  String get pixelLedMode => 'Pixel LED Matrix';

  @override
  String get pixelLedSubtitle => 'Simulate classic dot-matrix LED bulbs';

  @override
  String get dotShape => 'LED Bulb Shape';

  @override
  String get shapeCircle => 'Circle';

  @override
  String get shapeSquare => 'Square';

  @override
  String get shapeRounded => 'Rounded';

  @override
  String get shapeDiamond => 'Diamond';

  @override
  String get dotSize => 'LED Dot Size';

  @override
  String get grilleOpacity => 'Matrix Contrast';

  @override
  String get backgroundMode => 'Background Type';

  @override
  String get bgSolid => 'Color';

  @override
  String get bgTheme => 'Theme';

  @override
  String get bgImage => 'Photo';

  @override
  String get bgVideo => 'Video';

  @override
  String get backgroundColor => 'Background Color';

  @override
  String get themeCategory => 'Category';

  @override
  String get catAll => 'All';

  @override
  String get catGeneral => 'General';

  @override
  String get catConcert => 'Concert';

  @override
  String get catBirthday => 'Birthday';

  @override
  String get catHoliday => 'Holiday';

  @override
  String get pickImage => 'Choose Photo';

  @override
  String get pickVideo => 'Choose Video';

  @override
  String get clearMedia => 'Remove';

  @override
  String selectedFile(String name) {
    return 'Selected: $name';
  }

  @override
  String get backgroundDim => 'Background Dimmer';

  @override
  String get themeNeonGrid => 'Neon Grid';

  @override
  String get themeStarfield => 'Starfield';

  @override
  String get themeAurora => 'Aurora Wave';

  @override
  String get themeLaserParty => 'Laser Stage';

  @override
  String get themeDisco => 'Disco Spotlights';

  @override
  String get themeConfetti => 'Birthday Confetti';

  @override
  String get themeBalloons => 'Party Balloons';

  @override
  String get themeSnow => 'Winter Snow';

  @override
  String get themeFestiveLights => 'Festive Lights';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get musicNone => 'No Music';

  @override
  String get pickAudioFile => 'Pick Audio File';

  @override
  String get musicVolume => 'Music Volume';

  @override
  String get trackConcertPulse => 'Concert Pulse';

  @override
  String get trackBirthdayChime => 'Birthday Chime';

  @override
  String get trackFestiveBells => 'Festive Bells';

  @override
  String get trackNeonChill => 'Neon Chill';

  @override
  String get drawingOverlay => 'Freehand & Shape Drawing';

  @override
  String drawingStrokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strokes on banner',
      one: '1 stroke on banner',
      zero: 'No strokes yet',
    );
    return '$_temp0';
  }

  @override
  String get openDrawingBoard => 'Open Drawing Board';

  @override
  String get clearDrawings => 'Clear Drawings';

  @override
  String get quickTemplates => 'Quick Templates';

  @override
  String get touchLocked => 'Touch Locked';

  @override
  String get holdToUnlock => 'Hold to Unlock';

  @override
  String get unlockedMessage => 'Controls unlocked';

  @override
  String get brightnessLabel => 'Brightness';

  @override
  String get rotateScreen => 'Rotate';

  @override
  String get muteAudio => 'Mute';

  @override
  String get unmuteAudio => 'Unmute';

  @override
  String get lockTouch => 'Lock';

  @override
  String get drawingTitle => 'Drawing Board';

  @override
  String get toolFreehand => 'Pen';

  @override
  String get toolLine => 'Line';

  @override
  String get toolRect => 'Rect';

  @override
  String get toolCircle => 'Circle';

  @override
  String get toolHeart => 'Heart';

  @override
  String get toolStar => 'Star';

  @override
  String get brushColor => 'Brush Color';

  @override
  String get brushWidth => 'Stroke Width';

  @override
  String get neonStroke => 'Neon Glow';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get clearAll => 'Clear All';

  @override
  String get saveDrawing => 'Apply';

  @override
  String get historyTitle => 'Saved & Templates';

  @override
  String get tabHistory => 'History';

  @override
  String get tabTemplates => 'Templates';

  @override
  String get emptyHistory => 'No saved banners yet';

  @override
  String get emptyHistorySubtitle =>
      'Banners you play or save appear here for quick reuse.';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirm => 'Remove all unpinned history items?';

  @override
  String get savedToHistory => 'Saved to history';

  @override
  String get pinBanner => 'Pin';

  @override
  String get unpinBanner => 'Unpin';

  @override
  String get badgeLed => 'LED';

  @override
  String get badgeBlink => 'Blink';

  @override
  String get badgeMusic => 'Music';

  @override
  String get badgeDraw => 'Art';

  @override
  String get templateConcert => 'Concert Cheering';

  @override
  String get templateAirport => 'Airport Pickup';

  @override
  String get templateBirthday => 'Happy Birthday';

  @override
  String get templateChristmas => 'Merry Christmas';

  @override
  String get templateShopSale => 'Store Flash Sale';

  @override
  String get templateParty => 'Club Night Party';

  @override
  String get templateTaxi => 'Taxi / Need Ride';

  @override
  String get templateLove => 'Love Confession';

  @override
  String get exportTitle => 'Export MP4 Video';

  @override
  String get resolution => 'Resolution';

  @override
  String get res720p => 'HD 720p (1280×720)';

  @override
  String get res480p => 'SD 480p (854×480)';

  @override
  String get duration => 'Loop Duration';

  @override
  String durationAuto(String seconds) {
    return 'Auto (${seconds}s)';
  }

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get videoBgFallbackNote =>
      'Note: Custom video backgrounds are rendered over a dark studio background in MP4 export.';

  @override
  String get startExport => 'Export MP4';

  @override
  String exportingProgress(int percent) {
    return 'Encoding video... $percent%';
  }

  @override
  String get exportCancelled => 'Export cancelled';

  @override
  String get exportSuccess => 'Video ready!';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get shareVideo => 'Share MP4';

  @override
  String get savedToGallerySuccess => 'Saved to Photo Gallery!';

  @override
  String get exportUnsupportedPlatform =>
      'Hardware MP4 encoding is available on Android, iOS, and macOS.';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get langVietnamese => 'Tiếng Việt';

  @override
  String get langEnglish => 'English';

  @override
  String get themeMode => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get keepScreenAwake => 'Keep Screen Awake';

  @override
  String get keepScreenAwakeSub =>
      'Prevent screen from sleeping while displaying banner';

  @override
  String get forceLandscape => 'Auto Landscape Display';

  @override
  String get forceLandscapeSub =>
      'Switch to landscape mode when playing full screen';

  @override
  String get autoSaveHistory => 'Auto-Save to History';

  @override
  String get autoSaveHistorySub =>
      'Automatically save banners when played full screen';

  @override
  String get pickColorTitle => 'Select Color';

  @override
  String get hexCodeLabel => 'Hex Code';

  @override
  String get customColor => 'Custom Color';

  @override
  String get presetSwatches => 'Neon Swatches';
}
