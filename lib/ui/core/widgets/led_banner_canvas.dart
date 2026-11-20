import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

import '../../../domain/models/banner_config.dart';
import 'led_banner_painter.dart';
import 'led_grid_mask_cache.dart';

/// Live animated (or static thumbnail) LED banner surface.
///
/// Handles Ticker-driven animation, async custom photo decoding, muted looping
/// background video playback, and cached Pixel LED dot-matrix overlays.
class LedBannerCanvas extends StatefulWidget {
  const LedBannerCanvas({
    super.key,
    required this.config,
    this.isPlaying = true,
    this.enableVideoPlayback = true,
    this.forceCenterWhenPaused = false,
    this.borderRadius = BorderRadius.zero,
  });

  final BannerConfig config;
  final bool isPlaying;
  final bool enableVideoPlayback;
  final bool forceCenterWhenPaused;
  final BorderRadius borderRadius;

  @override
  State<LedBannerCanvas> createState() => _LedBannerCanvasState();
}

class _LedBannerCanvasState extends State<LedBannerCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  double _elapsedSeconds = 1.1;

  ui.Image? _loadedBgImage;
  String? _loadedBgImagePath;

  VideoPlayerController? _videoController;
  String? _loadedVideoPath;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.isPlaying) {
      _ticker.start();
    }
    _syncBackgroundMedia();
  }

  @override
  void didUpdateWidget(covariant LedBannerCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _lastTick = Duration.zero;
        if (!_ticker.isActive) {
          _ticker.start();
        }
      } else {
        _ticker.stop();
      }
    }

    if (widget.config.backgroundType != oldWidget.config.backgroundType ||
        widget.config.backgroundImagePath !=
            oldWidget.config.backgroundImagePath ||
        widget.config.backgroundVideoPath !=
            oldWidget.config.backgroundVideoPath ||
        widget.enableVideoPlayback != oldWidget.enableVideoPlayback) {
      _syncBackgroundMedia();
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1000000.0;
    _lastTick = elapsed;
    if (dt > 0 && dt < 0.25 && mounted) {
      setState(() {
        _elapsedSeconds += dt;
      });
    }
  }

  Future<void> _syncBackgroundMedia() async {
    final config = widget.config;

    // Load or dispose background photo.
    if (config.backgroundType == BackgroundType.image &&
        config.backgroundImagePath != null &&
        config.backgroundImagePath!.isNotEmpty) {
      if (_loadedBgImagePath != config.backgroundImagePath) {
        await _loadImage(config.backgroundImagePath!);
      }
    } else {
      _disposeLoadedImage();
    }

    // Load or dispose background video.
    if (widget.enableVideoPlayback &&
        config.backgroundType == BackgroundType.video &&
        config.backgroundVideoPath != null &&
        config.backgroundVideoPath!.isNotEmpty) {
      if (_loadedVideoPath != config.backgroundVideoPath) {
        await _loadVideo(config.backgroundVideoPath!);
      }
    } else {
      await _disposeVideo();
    }
  }

  Future<void> _loadImage(String path) async {
    _loadedBgImagePath = path;
    if (kIsWeb) return;
    try {
      final file = File(path);
      if (!await file.exists()) {
        _disposeLoadedImage();
        return;
      }
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted || _loadedBgImagePath != path) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _loadedBgImage?.dispose();
        _loadedBgImage = frame.image;
      });
    } catch (_) {
      _disposeLoadedImage();
    }
  }

  void _disposeLoadedImage() {
    _loadedBgImage?.dispose();
    _loadedBgImage = null;
    _loadedBgImagePath = null;
  }

  Future<void> _loadVideo(String path) async {
    await _disposeVideo();
    _loadedVideoPath = path;
    if (kIsWeb) return;

    try {
      final file = File(path);
      if (!await file.exists()) return;
      final controller = VideoPlayerController.file(file);
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();
      if (!mounted || _videoController != controller) {
        await controller.dispose();
        return;
      }
      setState(() {
        _videoReady = true;
      });
    } catch (_) {
      await _disposeVideo();
    }
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    _loadedVideoPath = null;
    if (_videoReady && mounted) {
      setState(() {
        _videoReady = false;
      });
    } else {
      _videoReady = false;
    }
    if (controller != null) {
      try {
        await controller.dispose();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _disposeLoadedImage();
    unawaited(_disposeVideo());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ui.Image? maskTile = widget.config.pixelLedEnabled
        ? LedGridMaskCache.getOrCreateTile(
            shape: widget.config.ledDotShape,
            grilleOpacity: widget.config.ledGrilleOpacity,
          )
        : null;

    final hasLiveVideo = _videoReady &&
        _videoController != null &&
        widget.config.backgroundType == BackgroundType.video;

    final shouldForceCenter =
        widget.forceCenterWhenPaused && !widget.isPlaying;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (hasLiveVideo)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width > 0
                      ? _videoController!.value.size.width
                      : 1280,
                  height: _videoController!.value.size.height > 0
                      ? _videoController!.value.size.height
                      : 720,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            CustomPaint(
              painter: LedBannerPainter(
                config: widget.config,
                elapsedSeconds: _elapsedSeconds,
                backgroundImage: _loadedBgImage,
                ledMaskTile: maskTile,
                hasLiveVideoBackground: hasLiveVideo,
                forceCenterText: shouldForceCenter,
              ),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}
