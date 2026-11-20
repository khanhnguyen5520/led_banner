import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/banner_config.dart';
import '../../ui/core/widgets/led_banner_painter.dart';
import '../../ui/core/widgets/led_grid_mask_cache.dart';

/// Exception thrown when the current platform does not support hardware MP4 export.
class UnsupportedExportPlatformException implements Exception {
  const UnsupportedExportPlatformException();
}

/// Renders [BannerConfig] frames offscreen and encodes them into an MP4 file.
class VideoExportService {
  bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<String?> exportBannerToMp4({
    required BannerConfig config,
    required int width,
    required int height,
    required double durationSeconds,
    int fps = 30,
    required void Function(double progress) onProgress,
    required bool Function() isCancelled,
  }) async {
    if (!isSupportedPlatform) {
      throw const UnsupportedExportPlatformException();
    }

    final evenWidth = width & ~1;
    final evenHeight = height & ~1;
    final totalFrames = (durationSeconds * fps).round().clamp(30, 600);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/led_banner_$timestamp.mp4';

    ui.Image? bgImage;
    ui.Image? maskTile;
    var encoderInitialized = false;

    try {
      if (config.backgroundType == BackgroundType.image &&
          config.backgroundImagePath != null &&
          config.backgroundImagePath!.isNotEmpty) {
        final file = File(config.backgroundImagePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frameInfo = await codec.getNextFrame();
          bgImage = frameInfo.image;
          codec.dispose();
        }
      }

      if (config.pixelLedEnabled) {
        maskTile = LedGridMaskCache.generateTile(
          shape: config.ledDotShape,
          grilleOpacity: config.ledGrilleOpacity,
        );
      }

      await FlutterQuickVideoEncoder.setLogLevel(LogLevel.error);
      await FlutterQuickVideoEncoder.setup(
        width: evenWidth,
        height: evenHeight,
        fps: fps,
        videoBitrate: evenWidth >= 1280 ? 4000000 : 2200000,
        profileLevel: ProfileLevel.any,
        audioChannels: 0,
        audioBitrate: 0,
        sampleRate: 0,
        filepath: outputPath,
      );
      encoderInitialized = true;

      final canvasSize = Size(evenWidth.toDouble(), evenHeight.toDouble());

      for (var i = 0; i < totalFrames; i++) {
        if (isCancelled()) {
          await FlutterQuickVideoEncoder.finish();
          encoderInitialized = false;
          final partial = File(outputPath);
          if (await partial.exists()) {
            await partial.delete();
          }
          return null;
        }

        final elapsedSeconds = i / fps;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(
          recorder,
          Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
        );

        final painter = LedBannerPainter(
          config: config,
          elapsedSeconds: elapsedSeconds,
          backgroundImage: bgImage,
          ledMaskTile: maskTile,
          hasLiveVideoBackground: false,
        );
        painter.paint(canvas, canvasSize);

        final picture = recorder.endRecording();
        final image = await picture.toImage(evenWidth, evenHeight);
        picture.dispose();

        final byteData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        image.dispose();

        if (byteData != null) {
          await FlutterQuickVideoEncoder.appendVideoFrame(
            byteData.buffer.asUint8List(),
          );
        }

        onProgress((i + 1) / totalFrames);
        // Yield briefly so the UI progress indicator remains responsive.
        await Future<void>.delayed(Duration.zero);
      }

      await FlutterQuickVideoEncoder.finish();
      encoderInitialized = false;
      return outputPath;
    } catch (_) {
      if (encoderInitialized) {
        try {
          await FlutterQuickVideoEncoder.finish();
        } catch (_) {}
      }
      rethrow;
    } finally {
      bgImage?.dispose();
      maskTile?.dispose();
    }
  }

  Future<void> saveToGallery(String filePath) async {
    await Gal.putVideo(filePath, album: 'LED Banner');
  }

  Future<void> shareVideo(String filePath, {Rect? sharePositionOrigin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(filePath)],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
