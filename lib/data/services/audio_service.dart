import 'package:audioplayers/audioplayers.dart';

import '../../domain/models/banner_config.dart';

/// Wraps `audioplayers` to loop built-in or user-picked background audio.
class AudioService {
  AudioService({this._player});

  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  AudioPlayer _getOrCreatePlayer() {
    return _player ??= AudioPlayer();
  }

  Future<void> playConfig(BannerConfig config) async {
    await playSource(
      config.musicSourceType,
      config.musicIdOrPath,
      config.musicVolume,
    );
  }

  Future<void> playSource(
    MusicSourceType sourceType,
    String? idOrPath,
    double volume,
  ) async {
    if (sourceType == MusicSourceType.none ||
        idOrPath == null ||
        idOrPath.isEmpty) {
      await stop();
      return;
    }

    try {
      final player = _getOrCreatePlayer();
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(volume.clamp(0.0, 1.0));
      final Source source = switch (sourceType) {
        MusicSourceType.builtIn => AssetSource(idOrPath),
        MusicSourceType.file => DeviceFileSource(idOrPath),
        MusicSourceType.none => AssetSource(''),
      };
      await player.play(source);
      _isPlaying = true;
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final player = _player;
      if (player != null) {
        await player.setVolume(volume.clamp(0.0, 1.0));
      }
    } catch (_) {
      // Ignore platform audio failures on unsupported hosts.
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    try {
      final player = _player;
      if (player != null) {
        await player.stop();
      }
    } catch (_) {
      // Ignore platform audio failures.
    }
  }

  Future<void> dispose() async {
    _isPlaying = false;
    try {
      final player = _player;
      _player = null;
      await player?.dispose();
    } catch (_) {
      // Ignore disposal errors.
    }
  }
}
