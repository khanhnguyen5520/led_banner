import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:led_banner/data/repositories/banner_repository.dart';
import 'package:led_banner/data/services/audio_service.dart';
import 'package:led_banner/data/services/local_storage_service.dart';
import 'package:led_banner/data/services/media_picker_service.dart';
import 'package:led_banner/domain/models/app_settings.dart';
import 'package:led_banner/domain/models/banner_config.dart';
import 'package:led_banner/domain/models/preset_templates.dart';
import 'package:led_banner/ui/features/editor/view_models/editor_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubAudioService extends AudioService {
  bool playCalled = false;
  bool stopCalled = false;
  double lastVolume = 1.0;

  @override
  Future<void> playConfig(BannerConfig config) async {
    playCalled = true;
  }

  @override
  Future<void> setVolume(double volume) async {
    lastVolume = volume;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
  }
}

class _StubMediaPickerService extends MediaPickerService {
  String? nextImage;
  String? nextVideo;
  PickedAudioFile? nextAudio;

  @override
  Future<String?> pickImagePath() async => nextImage;

  @override
  Future<String?> pickVideoPath() async => nextVideo;

  @override
  Future<PickedAudioFile?> pickAudioFile() async => nextAudio;
}

void main() {
  group('EditorViewModel', () {
    late _StubAudioService audioService;
    late _StubMediaPickerService pickerService;
    late EditorViewModel viewModel;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = LocalStorageService();
      final repo = BannerRepository(storageService: storage);
      audioService = _StubAudioService();
      pickerService = _StubMediaPickerService();
      viewModel = EditorViewModel(
        repository: repo,
        audioService: audioService,
        mediaPickerService: pickerService,
        random: Random(7),
      );
      await viewModel.init();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initializes defaults and updates text, motion, effects, and LED dot style', () {
      expect(viewModel.isInitialized, isTrue);

      viewModel.setText('SALE 50%');
      viewModel.appendEmoji('🔥');
      expect(viewModel.config.text, 'SALE 50% 🔥');

      viewModel.setDirection(ScrollDirection.right);
      viewModel.setSpeed(3.5);
      viewModel.setFontSizeFactor(0.8);
      viewModel.setLetterSpacing(5.0);
      viewModel.setFontId('oswald');
      viewModel.toggleBold();
      viewModel.toggleItalic();
      viewModel.toggleMirrored();

      expect(viewModel.config.direction, ScrollDirection.right);
      expect(viewModel.config.speed, 3.5);
      expect(viewModel.config.fontSizeFactor, 0.8);
      expect(viewModel.config.letterSpacing, 5.0);
      expect(viewModel.config.fontId, 'oswald');
      expect(viewModel.config.isBold, isFalse);
      expect(viewModel.config.isItalic, isTrue);
      expect(viewModel.config.isMirrored, isTrue);

      viewModel.setTextColorMode(TextColorMode.gradient);
      viewModel.setTextColor(0xFFFF0000);
      viewModel.setTextGradientEndColor(0xFF00FF00);
      viewModel.setGlowBlur(20.0);
      viewModel.setOutlineEnabled(true);
      viewModel.setOutlineColor(0xFFFFFFFF);
      viewModel.setOutlineWidth(6.0);
      viewModel.setBlinkEnabled(true);
      viewModel.setBlinkMode(BlinkMode.pulse);
      viewModel.setBlinkSpeed(4.5);

      expect(viewModel.config.textColorMode, TextColorMode.gradient);
      expect(viewModel.config.outlineEnabled, isTrue);
      expect(viewModel.config.blinkMode, BlinkMode.pulse);

      viewModel.setLedDotShape(LedDotShape.diamond);
      viewModel.setLedDotPitch(14.0);
      viewModel.setLedGrilleOpacity(0.75);
      expect(viewModel.config.ledDotShape, LedDotShape.diamond);
      expect(viewModel.config.ledDotPitch, 14.0);
      expect(viewModel.config.ledGrilleOpacity, 0.75);
    });

    test('media picking, music preview, and drawings work cleanly', () async {
      pickerService.nextImage = '/tmp/bg.png';
      expect(await viewModel.pickBackgroundImage(), isTrue);
      expect(viewModel.config.backgroundType, BackgroundType.image);
      expect(viewModel.config.backgroundImagePath, '/tmp/bg.png');
      viewModel.clearBackgroundImage();
      expect(viewModel.config.backgroundImagePath, isNull);

      pickerService.nextVideo = '/tmp/bg.mp4';
      expect(await viewModel.pickBackgroundVideo(), isTrue);
      expect(viewModel.config.backgroundType, BackgroundType.video);
      expect(viewModel.config.backgroundVideoPath, '/tmp/bg.mp4');

      await viewModel.selectBuiltInTrack(PresetTemplates.builtInTracks.first);
      expect(viewModel.config.musicSourceType, MusicSourceType.builtIn);

      await viewModel.togglePreviewMusic();
      expect(viewModel.isPreviewMusicPlaying, isTrue);
      expect(audioService.playCalled, isTrue);

      await viewModel.setMusicVolume(0.4);
      expect(audioService.lastVolume, 0.4);

      pickerService.nextAudio = const PickedAudioFile(
        path: '/tmp/song.mp3',
        name: 'song.mp3',
      );
      expect(await viewModel.pickCustomMusic(), isTrue);
      expect(viewModel.config.musicLabel, 'song.mp3');

      await viewModel.clearMusic();
      expect(viewModel.config.musicSourceType, MusicSourceType.none);
      expect(viewModel.isPreviewMusicPlaying, isFalse);

      viewModel.setDrawings(const <DrawingStroke>[
        DrawingStroke(
          tool: DrawingTool.star,
          points: <DrawingPoint>[DrawingPoint(0.1, 0.1), DrawingPoint(0.4, 0.4)],
          colorValue: 0xFF00F5FF,
          strokeWidth: 6.0,
        ),
      ]);
      expect(viewModel.config.drawings.length, 1);
      viewModel.clearDrawings();
      expect(viewModel.config.drawings, isEmpty);
    });

    test('history save, pin, delete, clear unpinned, and settings persist', () async {
      viewModel.setText('FIRST BANNER');
      await viewModel.saveCurrentToHistory();

      viewModel.setText('SECOND BANNER');
      await viewModel.saveCurrentToHistory();
      expect(viewModel.history.length, 2);

      // Pin the second item and verify pinning sorts it first.
      final firstAddedId = viewModel.history.last.id;
      await viewModel.togglePinHistory(firstAddedId);
      expect(viewModel.history.first.id, firstAddedId);
      expect(viewModel.history.first.isPinned, isTrue);

      // Clear unpinned should preserve the pinned entry.
      await viewModel.clearUnpinnedHistory();
      expect(viewModel.history.length, 1);
      expect(viewModel.history.first.isPinned, isTrue);

      await viewModel.deleteHistoryItem(firstAddedId);
      expect(viewModel.history, isEmpty);

      await viewModel.updateSettings(
        const AppSettings(
          localeCode: 'en',
          themeMode: AppThemeMode.light,
          keepScreenAwake: false,
          forceLandscape: false,
          autoSaveHistory: false,
        ),
      );
      expect(viewModel.settings.localeCode, 'en');
      expect(viewModel.settings.themeMode, AppThemeMode.light);

      final roundTripped = AppSettings.fromJson(viewModel.settings.toJson());
      expect(roundTripped.themeMode, AppThemeMode.light);
      expect(AppSettings.fromJson(const <String, dynamic>{}).themeMode, AppThemeMode.system);
      expect(
        AppSettings.fromJson(const <String, dynamic>{'themeMode': 'invalid'}).themeMode,
        AppThemeMode.system,
      );
      expect(viewModel.settings.keepScreenAwake, isFalse);
    });
  });
}
