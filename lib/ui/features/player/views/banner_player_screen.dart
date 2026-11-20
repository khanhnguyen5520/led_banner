import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/services/audio_service.dart';
import '../../../../data/services/brightness_service.dart';
import '../../../../data/services/video_export_service.dart';
import '../../../../data/services/wakelock_service.dart';
import '../../../../domain/models/app_settings.dart';
import '../../../../domain/models/banner_config.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/led_banner_canvas.dart';
import '../../export/views/export_video_dialog.dart';

/// Immersive full-screen LED banner display with brightness swipe & touch lock.
class BannerPlayerScreen extends StatefulWidget {
  const BannerPlayerScreen({
    super.key,
    required this.config,
    required this.settings,
    required this.audioService,
    required this.brightnessService,
    required this.wakelockService,
    required this.videoExportService,
    this.onAutoSave,
  });

  final BannerConfig config;
  final AppSettings settings;
  final AudioService audioService;
  final BrightnessService brightnessService;
  final WakelockService wakelockService;
  final VideoExportService videoExportService;
  final VoidCallback? onAutoSave;

  @override
  State<BannerPlayerScreen> createState() => _BannerPlayerScreenState();
}

class _BannerPlayerScreenState extends State<BannerPlayerScreen> {
  late BannerConfig _localConfig;
  bool _isPlaying = true;
  bool _isLocked = false;
  bool _isMuted = false;
  bool _isLandscape = true;
  bool _showControls = true;
  bool _showBrightnessHud = false;
  bool _showLockedHint = false;
  double _brightness = 0.75;

  Timer? _controlsHideTimer;
  Timer? _brightnessHudTimer;
  Timer? _lockedHintTimer;

  @override
  void initState() {
    super.initState();
    _localConfig = widget.config;
    _isLandscape = widget.settings.forceLandscape;
    _enterImmersiveMode();
    _initServices();
    _scheduleControlsAutoHide();

    if (widget.settings.autoSaveHistory && widget.onAutoSave != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onAutoSave!();
      });
    }
  }

  Future<void> _enterImmersiveMode() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (widget.settings.forceLandscape) {
        await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (_) {}
  }

  Future<void> _initServices() async {
    if (widget.settings.keepScreenAwake) {
      await widget.wakelockService.setEnabled(true);
    }
    final currentBrightness = await widget.brightnessService.getCurrentBrightness();
    if (mounted) {
      setState(() {
        _brightness = currentBrightness;
      });
    }
    if (_localConfig.musicSourceType != MusicSourceType.none) {
      await widget.audioService.playConfig(_localConfig);
    }
  }

  void _scheduleControlsAutoHide() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _handleTap() {
    if (_isLocked) {
      setState(() {
        _showLockedHint = true;
      });
      _lockedHintTimer?.cancel();
      _lockedHintTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showLockedHint = false;
          });
        }
      });
      return;
    }

    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _scheduleControlsAutoHide();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_isLocked) return;
    final next = (_brightness - details.delta.dy / 300.0).clamp(0.05, 1.0);
    setState(() {
      _brightness = next;
      _showBrightnessHud = true;
    });
    widget.brightnessService.setBrightness(next);
    _brightnessHudTimer?.cancel();
    _brightnessHudTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _showBrightnessHud = false;
        });
      }
    });
  }

  void _lockTouch() {
    _controlsHideTimer?.cancel();
    setState(() {
      _isLocked = true;
      _showControls = false;
      _showLockedHint = true;
    });
    _lockedHintTimer?.cancel();
    _lockedHintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showLockedHint = false;
        });
      }
    });
  }

  void _unlockTouch() {
    _lockedHintTimer?.cancel();
    setState(() {
      _isLocked = false;
      _showLockedHint = false;
      _showControls = true;
    });
    _scheduleControlsAutoHide();
  }

  Future<void> _toggleMute() async {
    final nextMuted = !_isMuted;
    setState(() {
      _isMuted = nextMuted;
    });
    await widget.audioService.setVolume(nextMuted ? 0.0 : _localConfig.musicVolume);
    _scheduleControlsAutoHide();
  }

  Future<void> _toggleOrientation() async {
    final nextLandscape = !_isLandscape;
    setState(() {
      _isLandscape = nextLandscape;
    });
    try {
      if (nextLandscape) {
        await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
          DeviceOrientation.portraitUp,
        ]);
      }
    } catch (_) {}
    _scheduleControlsAutoHide();
  }

  void _toggleMirror() {
    setState(() {
      _localConfig = _localConfig.copyWith(isMirrored: !_localConfig.isMirrored);
    });
    _scheduleControlsAutoHide();
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    _brightnessHudTimer?.cancel();
    _lockedHintTimer?.cancel();
    unawaited(widget.audioService.stop());
    unawaited(widget.wakelockService.setEnabled(false));
    unawaited(widget.brightnessService.resetBrightness());
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    );
    unawaited(
      SystemChrome.setPreferredOrientations(DeviceOrientation.values),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMusic = _localConfig.musicSourceType != MusicSourceType.none;

    return PopScope(
      canPop: !_isLocked,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onVerticalDragUpdate: _handleVerticalDragUpdate,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              LedBannerCanvas(
                config: _localConfig,
                isPlaying: _isPlaying,
              ),

              // Brightness HUD indicator on vertical swipe.
              if (_showBrightnessHud && !_isLocked)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.brightness_6_rounded,
                          color: AppTheme.primaryCyan,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.brightnessLabel} ${(_brightness * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            value: _brightness,
                            backgroundColor: Colors.white24,
                            color: AppTheme.primaryCyan,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Floating playback controls bar.
              if (_showControls && !_isLocked)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.68),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                tooltip: l10n.close,
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                tooltip: _isPlaying ? l10n.pause : l10n.play,
                                onPressed: () {
                                  setState(() {
                                    _isPlaying = !_isPlaying;
                                  });
                                  _scheduleControlsAutoHide();
                                },
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: AppTheme.primaryCyan,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.lockTouch,
                                onPressed: _lockTouch,
                                icon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              if (hasMusic)
                                IconButton(
                                  tooltip:
                                      _isMuted ? l10n.unmuteAudio : l10n.muteAudio,
                                  onPressed: _toggleMute,
                                  icon: Icon(
                                    _isMuted
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              IconButton(
                                tooltip: l10n.rotateScreen,
                                onPressed: _toggleOrientation,
                                icon: const Icon(
                                  Icons.screen_rotation_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.mirror,
                                onPressed: _toggleMirror,
                                icon: Icon(
                                  Icons.flip_rounded,
                                  color: _localConfig.isMirrored
                                      ? AppTheme.primaryCyan
                                      : Colors.white,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.exportTooltip,
                                onPressed: () {
                                  _controlsHideTimer?.cancel();
                                  showExportVideoDialog(
                                    context,
                                    config: _localConfig,
                                    exportService: widget.videoExportService,
                                  );
                                },
                                icon: const Icon(
                                  Icons.ios_share_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Touch-lock status / long-press unlock pill.
              if (_isLocked && _showLockedHint)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: GestureDetector(
                        onLongPress: _unlockTouch,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppTheme.primaryCyan.withValues(alpha: 0.65),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.lock_rounded,
                                color: AppTheme.primaryCyan,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${l10n.touchLocked} · ${l10n.holdToUnlock}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
