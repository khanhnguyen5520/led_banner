import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/banner_repository.dart';
import '../../../../data/services/audio_service.dart';
import '../../../../data/services/media_picker_service.dart';
import '../../../../domain/models/app_settings.dart';
import '../../../../domain/models/banner_config.dart';
import '../../../../domain/models/banner_history_item.dart';
import '../../../../domain/models/preset_templates.dart';

/// Presentation state & commands for the LED Banner studio editor and history.
class EditorViewModel extends ChangeNotifier {
  EditorViewModel({
    required this._repository,
    required this._audioService,
    required this._mediaPickerService,
    Random? random,
  }) : _random = random ?? Random();

  final BannerRepository _repository;
  final AudioService _audioService;
  final MediaPickerService _mediaPickerService;
  final Random _random;

  BannerConfig _config = const BannerConfig();
  BannerConfig get config => _config;

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  List<BannerHistoryItem> _history = const <BannerHistoryItem>[];
  List<BannerHistoryItem> get history => _history;

  bool _isPreviewPlaying = true;
  bool get isPreviewPlaying => _isPreviewPlaying;

  bool _isPreviewMusicPlaying = false;
  bool get isPreviewMusicPlaying => _isPreviewMusicPlaying;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Timer? _persistDebounce;

  Future<void> init() async {
    final results = await Future.wait<Object>(<Future<Object>>[
      _repository.loadCurrentConfig(),
      _repository.loadSettings(),
      _repository.loadHistory(),
    ]);
    _config = results[0] as BannerConfig;
    _settings = results[1] as AppSettings;
    _history = results[2] as List<BannerHistoryItem>;
    _isInitialized = true;
    notifyListeners();
  }

  void setSelectedTab(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
  }

  void togglePreviewPlaying() {
    _isPreviewPlaying = !_isPreviewPlaying;
    notifyListeners();
  }

  void _updateConfig(BannerConfig next) {
    if (next == _config) return;
    _config = next;
    notifyListeners();
    _scheduleConfigPersist();
  }

  void _scheduleConfigPersist() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 300), () {
      _repository.saveCurrentConfig(_config);
    });
  }

  // --- Text & Motion Controls ---

  void setText(String text) => _updateConfig(_config.copyWith(text: text));

  void appendEmoji(String emoji) {
    final needsSpace = _config.text.isNotEmpty && !_config.text.endsWith(' ');
    final nextText = '${_config.text}${needsSpace ? ' ' : ''}$emoji';
    _updateConfig(_config.copyWith(text: nextText));
  }

  void setDirection(ScrollDirection direction) =>
      _updateConfig(_config.copyWith(direction: direction));

  void setSpeed(double speed) =>
      _updateConfig(_config.copyWith(speed: speed.clamp(0.0, 5.0)));

  void setFontSizeFactor(double factor) =>
      _updateConfig(_config.copyWith(fontSizeFactor: factor.clamp(0.25, 0.95)));

  void setLetterSpacing(double spacing) =>
      _updateConfig(_config.copyWith(letterSpacing: spacing.clamp(-2.0, 16.0)));

  void setFontId(String fontId) => _updateConfig(_config.copyWith(fontId: fontId));

  void toggleBold() => _updateConfig(_config.copyWith(isBold: !_config.isBold));

  void toggleItalic() =>
      _updateConfig(_config.copyWith(isItalic: !_config.isItalic));

  void toggleMirrored() =>
      _updateConfig(_config.copyWith(isMirrored: !_config.isMirrored));

  // --- Effects & Colors ---

  void setTextColorMode(TextColorMode mode) =>
      _updateConfig(_config.copyWith(textColorMode: mode));

  void setTextColor(int colorValue) =>
      _updateConfig(_config.copyWith(textColorValue: colorValue));

  void setTextGradientEndColor(int colorValue) =>
      _updateConfig(_config.copyWith(textGradientEndColorValue: colorValue));

  void setGlowBlur(double blur) =>
      _updateConfig(_config.copyWith(glowBlur: blur.clamp(0.0, 28.0)));

  void setOutlineEnabled(bool enabled) =>
      _updateConfig(_config.copyWith(outlineEnabled: enabled));

  void setOutlineColor(int colorValue) =>
      _updateConfig(_config.copyWith(outlineColorValue: colorValue));

  void setOutlineWidth(double width) =>
      _updateConfig(_config.copyWith(outlineWidth: width.clamp(1.0, 12.0)));

  void setBlinkEnabled(bool enabled) =>
      _updateConfig(_config.copyWith(blinkEnabled: enabled));

  void setBlinkMode(BlinkMode mode) =>
      _updateConfig(_config.copyWith(blinkMode: mode));

  void setBlinkSpeed(double speed) =>
      _updateConfig(_config.copyWith(blinkSpeed: speed.clamp(1.0, 6.0)));

  // --- Pixel LED Mode ---

  void setPixelLedEnabled(bool enabled) =>
      _updateConfig(_config.copyWith(pixelLedEnabled: enabled));

  void setLedDotShape(LedDotShape shape) =>
      _updateConfig(_config.copyWith(ledDotShape: shape));

  void setLedDotPitch(double pitch) =>
      _updateConfig(_config.copyWith(ledDotPitch: pitch.clamp(6.0, 22.0)));

  void setLedGrilleOpacity(double opacity) =>
      _updateConfig(_config.copyWith(ledGrilleOpacity: opacity.clamp(0.35, 1.0)));

  // --- Background Controls ---

  void setBackgroundType(BackgroundType type) =>
      _updateConfig(_config.copyWith(backgroundType: type));

  void setBackgroundColor(int colorValue) => _updateConfig(
        _config.copyWith(
          backgroundType: BackgroundType.solid,
          backgroundColorValue: colorValue,
        ),
      );

  void setThemePreset(ThemePresetId presetId) => _updateConfig(
        _config.copyWith(
          backgroundType: BackgroundType.theme,
          themePresetId: presetId,
        ),
      );

  void setBackgroundDim(double dim) =>
      _updateConfig(_config.copyWith(backgroundDim: dim.clamp(0.0, 0.85)));

  Future<bool> pickBackgroundImage() async {
    final path = await _mediaPickerService.pickImagePath();
    if (path == null) return false;
    _updateConfig(
      _config.copyWith(
        backgroundType: BackgroundType.image,
        backgroundImagePath: path,
      ),
    );
    return true;
  }

  void clearBackgroundImage() {
    _updateConfig(
      _config.copyWith(
        backgroundType: BackgroundType.solid,
        clearBackgroundImagePath: true,
      ),
    );
  }

  Future<bool> pickBackgroundVideo() async {
    final path = await _mediaPickerService.pickVideoPath();
    if (path == null) return false;
    _updateConfig(
      _config.copyWith(
        backgroundType: BackgroundType.video,
        backgroundVideoPath: path,
      ),
    );
    return true;
  }

  void clearBackgroundVideo() {
    _updateConfig(
      _config.copyWith(
        backgroundType: BackgroundType.solid,
        clearBackgroundVideoPath: true,
      ),
    );
  }

  // --- Drawings ---

  void setDrawings(List<DrawingStroke> drawings) {
    _updateConfig(_config.copyWith(drawings: List<DrawingStroke>.unmodifiable(drawings)));
  }

  void clearDrawings() {
    _updateConfig(_config.copyWith(drawings: const <DrawingStroke>[]));
  }

  // --- Music ---

  Future<void> clearMusic() async {
    await stopPreviewMusic();
    _updateConfig(
      _config.copyWith(
        musicSourceType: MusicSourceType.none,
        clearMusicIdOrPath: true,
        clearMusicLabel: true,
      ),
    );
  }

  Future<void> selectBuiltInTrack(BuiltInTrack track) async {
    _updateConfig(
      _config.copyWith(
        musicSourceType: MusicSourceType.builtIn,
        musicIdOrPath: track.assetPath,
        musicLabel: track.id,
      ),
    );
    if (_isPreviewMusicPlaying) {
      await _audioService.playConfig(_config);
    }
  }

  Future<bool> pickCustomMusic() async {
    final picked = await _mediaPickerService.pickAudioFile();
    if (picked == null) return false;
    _updateConfig(
      _config.copyWith(
        musicSourceType: MusicSourceType.file,
        musicIdOrPath: picked.path,
        musicLabel: picked.name,
      ),
    );
    if (_isPreviewMusicPlaying) {
      await _audioService.playConfig(_config);
    }
    return true;
  }

  Future<void> setMusicVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    _updateConfig(_config.copyWith(musicVolume: clamped));
    await _audioService.setVolume(clamped);
  }

  Future<void> togglePreviewMusic() async {
    if (_config.musicSourceType == MusicSourceType.none) return;
    if (_isPreviewMusicPlaying) {
      await stopPreviewMusic();
    } else {
      await _audioService.playConfig(_config);
      _isPreviewMusicPlaying = true;
      notifyListeners();
    }
  }

  Future<void> stopPreviewMusic() async {
    await _audioService.stop();
    if (_isPreviewMusicPlaying) {
      _isPreviewMusicPlaying = false;
      notifyListeners();
    }
  }

  // --- Style Presets & History ---

  void applyRandomStyle() {
    _updateConfig(PresetTemplates.randomStyle(_config, _random));
  }

  void applyTemplate(BannerConfig templateConfig) {
    _updateConfig(templateConfig);
  }

  Future<void> saveCurrentToHistory() async {
    _history = await _repository.saveToHistory(_config, _history);
    notifyListeners();
  }

  void loadHistoryItem(BannerHistoryItem item) {
    _updateConfig(item.config);
  }

  Future<void> togglePinHistory(String id) async {
    _history = await _repository.togglePin(id, _history);
    notifyListeners();
  }

  Future<void> deleteHistoryItem(String id) async {
    _history = await _repository.deleteHistoryItem(id, _history);
    notifyListeners();
  }

  Future<void> clearUnpinnedHistory() async {
    _history = await _repository.clearUnpinnedHistory(_history);
    notifyListeners();
  }

  // --- App Settings ---

  Future<void> updateSettings(AppSettings next) async {
    if (next == _settings) return;
    _settings = next;
    notifyListeners();
    await _repository.saveSettings(next);
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    super.dispose();
  }
}
