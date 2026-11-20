import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LED Banner'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @historyTooltip.
  ///
  /// In en, this message translates to:
  /// **'History & Templates'**
  String get historyTooltip;

  /// No description provided for @randomizeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Random Style'**
  String get randomizeTooltip;

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export MP4'**
  String get exportTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @playFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Play Full Screen'**
  String get playFullScreen;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your LED message...'**
  String get messageHint;

  /// No description provided for @clearText.
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get clearText;

  /// No description provided for @drawShortcut.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get drawShortcut;

  /// No description provided for @randomStyleApplied.
  ///
  /// In en, this message translates to:
  /// **'Random LED style applied!'**
  String get randomStyleApplied;

  /// No description provided for @tabText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get tabText;

  /// No description provided for @tabEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get tabEffects;

  /// No description provided for @tabLedStyle.
  ///
  /// In en, this message translates to:
  /// **'LED Dots'**
  String get tabLedStyle;

  /// No description provided for @tabBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get tabBackground;

  /// No description provided for @tabMediaDraw.
  ///
  /// In en, this message translates to:
  /// **'Music & Draw'**
  String get tabMediaDraw;

  /// No description provided for @scrollDirection.
  ///
  /// In en, this message translates to:
  /// **'Scroll Direction'**
  String get scrollDirection;

  /// No description provided for @dirLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get dirLeft;

  /// No description provided for @dirStatic.
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get dirStatic;

  /// No description provided for @dirRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get dirRight;

  /// No description provided for @scrollSpeed.
  ///
  /// In en, this message translates to:
  /// **'Scroll Speed'**
  String get scrollSpeed;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @letterSpacing.
  ///
  /// In en, this message translates to:
  /// **'Letter Spacing'**
  String get letterSpacing;

  /// No description provided for @textStyle.
  ///
  /// In en, this message translates to:
  /// **'Text Style'**
  String get textStyle;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @mirror.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get mirror;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @fontDefault.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get fontDefault;

  /// No description provided for @colorMode.
  ///
  /// In en, this message translates to:
  /// **'Text Color Mode'**
  String get colorMode;

  /// No description provided for @modeSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get modeSolid;

  /// No description provided for @modeGradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get modeGradient;

  /// No description provided for @modeRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow'**
  String get modeRainbow;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @gradientEndColor.
  ///
  /// In en, this message translates to:
  /// **'Gradient End Color'**
  String get gradientEndColor;

  /// No description provided for @neonGlow.
  ///
  /// In en, this message translates to:
  /// **'Neon Glow / Blur'**
  String get neonGlow;

  /// No description provided for @textOutline.
  ///
  /// In en, this message translates to:
  /// **'Text Outline'**
  String get textOutline;

  /// No description provided for @outlineColor.
  ///
  /// In en, this message translates to:
  /// **'Outline Color'**
  String get outlineColor;

  /// No description provided for @outlineWidth.
  ///
  /// In en, this message translates to:
  /// **'Outline Thickness'**
  String get outlineWidth;

  /// No description provided for @blinkEffect.
  ///
  /// In en, this message translates to:
  /// **'Blink Effect'**
  String get blinkEffect;

  /// No description provided for @blinkMode.
  ///
  /// In en, this message translates to:
  /// **'Blink Style'**
  String get blinkMode;

  /// No description provided for @blinkSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp Flash'**
  String get blinkSharp;

  /// No description provided for @blinkPulse.
  ///
  /// In en, this message translates to:
  /// **'Smooth Pulse'**
  String get blinkPulse;

  /// No description provided for @blinkSpeed.
  ///
  /// In en, this message translates to:
  /// **'Blink Speed'**
  String get blinkSpeed;

  /// No description provided for @hzUnit.
  ///
  /// In en, this message translates to:
  /// **'{value} Hz'**
  String hzUnit(String value);

  /// No description provided for @pixelLedMode.
  ///
  /// In en, this message translates to:
  /// **'Pixel LED Matrix'**
  String get pixelLedMode;

  /// No description provided for @pixelLedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simulate classic dot-matrix LED bulbs'**
  String get pixelLedSubtitle;

  /// No description provided for @dotShape.
  ///
  /// In en, this message translates to:
  /// **'LED Bulb Shape'**
  String get dotShape;

  /// No description provided for @shapeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get shapeCircle;

  /// No description provided for @shapeSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get shapeSquare;

  /// No description provided for @shapeRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get shapeRounded;

  /// No description provided for @shapeDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get shapeDiamond;

  /// No description provided for @dotSize.
  ///
  /// In en, this message translates to:
  /// **'LED Dot Size'**
  String get dotSize;

  /// No description provided for @grilleOpacity.
  ///
  /// In en, this message translates to:
  /// **'Matrix Contrast'**
  String get grilleOpacity;

  /// No description provided for @backgroundMode.
  ///
  /// In en, this message translates to:
  /// **'Background Type'**
  String get backgroundMode;

  /// No description provided for @bgSolid.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get bgSolid;

  /// No description provided for @bgTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get bgTheme;

  /// No description provided for @bgImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get bgImage;

  /// No description provided for @bgVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get bgVideo;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @themeCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get themeCategory;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get catGeneral;

  /// No description provided for @catConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert'**
  String get catConcert;

  /// No description provided for @catBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get catBirthday;

  /// No description provided for @catHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get catHoliday;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo'**
  String get pickImage;

  /// No description provided for @pickVideo.
  ///
  /// In en, this message translates to:
  /// **'Choose Video'**
  String get pickVideo;

  /// No description provided for @clearMedia.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get clearMedia;

  /// No description provided for @selectedFile.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selectedFile(String name);

  /// No description provided for @backgroundDim.
  ///
  /// In en, this message translates to:
  /// **'Background Dimmer'**
  String get backgroundDim;

  /// No description provided for @themeNeonGrid.
  ///
  /// In en, this message translates to:
  /// **'Neon Grid'**
  String get themeNeonGrid;

  /// No description provided for @themeStarfield.
  ///
  /// In en, this message translates to:
  /// **'Starfield'**
  String get themeStarfield;

  /// No description provided for @themeAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora Wave'**
  String get themeAurora;

  /// No description provided for @themeLaserParty.
  ///
  /// In en, this message translates to:
  /// **'Laser Stage'**
  String get themeLaserParty;

  /// No description provided for @themeDisco.
  ///
  /// In en, this message translates to:
  /// **'Disco Spotlights'**
  String get themeDisco;

  /// No description provided for @themeConfetti.
  ///
  /// In en, this message translates to:
  /// **'Birthday Confetti'**
  String get themeConfetti;

  /// No description provided for @themeBalloons.
  ///
  /// In en, this message translates to:
  /// **'Party Balloons'**
  String get themeBalloons;

  /// No description provided for @themeSnow.
  ///
  /// In en, this message translates to:
  /// **'Winter Snow'**
  String get themeSnow;

  /// No description provided for @themeFestiveLights.
  ///
  /// In en, this message translates to:
  /// **'Festive Lights'**
  String get themeFestiveLights;

  /// No description provided for @backgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// No description provided for @musicNone.
  ///
  /// In en, this message translates to:
  /// **'No Music'**
  String get musicNone;

  /// No description provided for @pickAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Pick Audio File'**
  String get pickAudioFile;

  /// No description provided for @musicVolume.
  ///
  /// In en, this message translates to:
  /// **'Music Volume'**
  String get musicVolume;

  /// No description provided for @trackConcertPulse.
  ///
  /// In en, this message translates to:
  /// **'Concert Pulse'**
  String get trackConcertPulse;

  /// No description provided for @trackBirthdayChime.
  ///
  /// In en, this message translates to:
  /// **'Birthday Chime'**
  String get trackBirthdayChime;

  /// No description provided for @trackFestiveBells.
  ///
  /// In en, this message translates to:
  /// **'Festive Bells'**
  String get trackFestiveBells;

  /// No description provided for @trackNeonChill.
  ///
  /// In en, this message translates to:
  /// **'Neon Chill'**
  String get trackNeonChill;

  /// No description provided for @drawingOverlay.
  ///
  /// In en, this message translates to:
  /// **'Freehand & Shape Drawing'**
  String get drawingOverlay;

  /// No description provided for @drawingStrokeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No strokes yet} =1{1 stroke on banner} other{{count} strokes on banner}}'**
  String drawingStrokeCount(int count);

  /// No description provided for @openDrawingBoard.
  ///
  /// In en, this message translates to:
  /// **'Open Drawing Board'**
  String get openDrawingBoard;

  /// No description provided for @clearDrawings.
  ///
  /// In en, this message translates to:
  /// **'Clear Drawings'**
  String get clearDrawings;

  /// No description provided for @quickTemplates.
  ///
  /// In en, this message translates to:
  /// **'Quick Templates'**
  String get quickTemplates;

  /// No description provided for @touchLocked.
  ///
  /// In en, this message translates to:
  /// **'Touch Locked'**
  String get touchLocked;

  /// No description provided for @holdToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Hold to Unlock'**
  String get holdToUnlock;

  /// No description provided for @unlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Controls unlocked'**
  String get unlockedMessage;

  /// No description provided for @brightnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightnessLabel;

  /// No description provided for @rotateScreen.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotateScreen;

  /// No description provided for @muteAudio.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get muteAudio;

  /// No description provided for @unmuteAudio.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmuteAudio;

  /// No description provided for @lockTouch.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lockTouch;

  /// No description provided for @drawingTitle.
  ///
  /// In en, this message translates to:
  /// **'Drawing Board'**
  String get drawingTitle;

  /// No description provided for @toolFreehand.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get toolFreehand;

  /// No description provided for @toolLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get toolLine;

  /// No description provided for @toolRect.
  ///
  /// In en, this message translates to:
  /// **'Rect'**
  String get toolRect;

  /// No description provided for @toolCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get toolCircle;

  /// No description provided for @toolHeart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get toolHeart;

  /// No description provided for @toolStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get toolStar;

  /// No description provided for @brushColor.
  ///
  /// In en, this message translates to:
  /// **'Brush Color'**
  String get brushColor;

  /// No description provided for @brushWidth.
  ///
  /// In en, this message translates to:
  /// **'Stroke Width'**
  String get brushWidth;

  /// No description provided for @neonStroke.
  ///
  /// In en, this message translates to:
  /// **'Neon Glow'**
  String get neonStroke;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @saveDrawing.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get saveDrawing;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved & Templates'**
  String get historyTitle;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get tabTemplates;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved banners yet'**
  String get emptyHistory;

  /// No description provided for @emptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Banners you play or save appear here for quick reuse.'**
  String get emptyHistorySubtitle;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all unpinned history items?'**
  String get clearHistoryConfirm;

  /// No description provided for @savedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved to history'**
  String get savedToHistory;

  /// No description provided for @pinBanner.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pinBanner;

  /// No description provided for @unpinBanner.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinBanner;

  /// No description provided for @badgeLed.
  ///
  /// In en, this message translates to:
  /// **'LED'**
  String get badgeLed;

  /// No description provided for @badgeBlink.
  ///
  /// In en, this message translates to:
  /// **'Blink'**
  String get badgeBlink;

  /// No description provided for @badgeMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get badgeMusic;

  /// No description provided for @badgeDraw.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get badgeDraw;

  /// No description provided for @templateConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert Cheering'**
  String get templateConcert;

  /// No description provided for @templateAirport.
  ///
  /// In en, this message translates to:
  /// **'Airport Pickup'**
  String get templateAirport;

  /// No description provided for @templateBirthday.
  ///
  /// In en, this message translates to:
  /// **'Happy Birthday'**
  String get templateBirthday;

  /// No description provided for @templateChristmas.
  ///
  /// In en, this message translates to:
  /// **'Merry Christmas'**
  String get templateChristmas;

  /// No description provided for @templateShopSale.
  ///
  /// In en, this message translates to:
  /// **'Store Flash Sale'**
  String get templateShopSale;

  /// No description provided for @templateParty.
  ///
  /// In en, this message translates to:
  /// **'Club Night Party'**
  String get templateParty;

  /// No description provided for @templateTaxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi / Need Ride'**
  String get templateTaxi;

  /// No description provided for @templateLove.
  ///
  /// In en, this message translates to:
  /// **'Love Confession'**
  String get templateLove;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export MP4 Video'**
  String get exportTitle;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @res720p.
  ///
  /// In en, this message translates to:
  /// **'HD 720p (1280×720)'**
  String get res720p;

  /// No description provided for @res480p.
  ///
  /// In en, this message translates to:
  /// **'SD 480p (854×480)'**
  String get res480p;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Loop Duration'**
  String get duration;

  /// No description provided for @durationAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto ({seconds}s)'**
  String durationAuto(String seconds);

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsShort(int seconds);

  /// No description provided for @videoBgFallbackNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Custom video backgrounds are rendered over a dark studio background in MP4 export.'**
  String get videoBgFallbackNote;

  /// No description provided for @startExport.
  ///
  /// In en, this message translates to:
  /// **'Export MP4'**
  String get startExport;

  /// No description provided for @exportingProgress.
  ///
  /// In en, this message translates to:
  /// **'Encoding video... {percent}%'**
  String exportingProgress(int percent);

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get exportCancelled;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video ready!'**
  String get exportSuccess;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @shareVideo.
  ///
  /// In en, this message translates to:
  /// **'Share MP4'**
  String get shareVideo;

  /// No description provided for @savedToGallerySuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved to Photo Gallery!'**
  String get savedToGallerySuccess;

  /// No description provided for @exportUnsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Hardware MP4 encoding is available on Android, iOS, and macOS.'**
  String get exportUnsupportedPlatform;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get langVietnamese;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @keepScreenAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen Awake'**
  String get keepScreenAwake;

  /// No description provided for @keepScreenAwakeSub.
  ///
  /// In en, this message translates to:
  /// **'Prevent screen from sleeping while displaying banner'**
  String get keepScreenAwakeSub;

  /// No description provided for @forceLandscape.
  ///
  /// In en, this message translates to:
  /// **'Auto Landscape Display'**
  String get forceLandscape;

  /// No description provided for @forceLandscapeSub.
  ///
  /// In en, this message translates to:
  /// **'Switch to landscape mode when playing full screen'**
  String get forceLandscapeSub;

  /// No description provided for @autoSaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Auto-Save to History'**
  String get autoSaveHistory;

  /// No description provided for @autoSaveHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Automatically save banners when played full screen'**
  String get autoSaveHistorySub;

  /// No description provided for @pickColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get pickColorTitle;

  /// No description provided for @hexCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Hex Code'**
  String get hexCodeLabel;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @presetSwatches.
  ///
  /// In en, this message translates to:
  /// **'Neon Swatches'**
  String get presetSwatches;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
