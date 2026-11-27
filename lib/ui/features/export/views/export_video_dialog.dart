import 'package:flutter/material.dart';

import '../../../../data/services/video_export_service.dart';
import '../../../../domain/models/banner_config.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/led_banner_painter.dart';

/// Opens the MP4 video export modal dialog for the given [config].
Future<void> showExportVideoDialog(
  BuildContext context, {
  required BannerConfig config,
  required VideoExportService exportService,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ExportVideoDialog(
      config: config,
      exportService: exportService,
    ),
  );
}

class _ExportVideoDialog extends StatefulWidget {
  const _ExportVideoDialog({
    required this.config,
    required this.exportService,
  });

  final BannerConfig config;
  final VideoExportService exportService;

  @override
  State<_ExportVideoDialog> createState() => _ExportVideoDialogState();
}

class _ExportVideoDialogState extends State<_ExportVideoDialog> {
  bool _isHd720 = true;
  int _selectedDurationOption = 0; // 0 = auto, else seconds
  bool _isExporting = false;
  bool _isCancelled = false;
  double _progress = 0.0;
  String? _exportedPath;
  String? _errorMessage;
  bool _savedToGallery = false;

  double get _autoDuration =>
      LedBannerPainter.estimateScrollCycleSeconds(widget.config);

  double get _effectiveDuration =>
      _selectedDurationOption == 0 ? _autoDuration : _selectedDurationOption.toDouble();

  Future<void> _startExport() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isExporting = true;
      _isCancelled = false;
      _progress = 0.0;
      _exportedPath = null;
      _errorMessage = null;
      _savedToGallery = false;
    });

    final width = _isHd720 ? 1280 : 854;
    final height = _isHd720 ? 720 : 480;

    try {
      final path = await widget.exportService.exportBannerToMp4(
        config: widget.config,
        width: width,
        height: height,
        durationSeconds: _effectiveDuration,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        },
        isCancelled: () => _isCancelled,
      );
      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _exportedPath = path;
        if (path == null && _isCancelled) {
          _errorMessage = l10n.exportCancelled;
        }
      });
    } on UnsupportedExportPlatformException {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _errorMessage = l10n.exportUnsupportedPlatform;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _errorMessage = l10n.exportFailed(e.toString());
      });
    }
  }

  Future<void> _saveToGallery() async {
    final path = _exportedPath;
    if (path == null) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      await widget.exportService.saveToGallery(path);
      if (!mounted) return;
      setState(() {
        _savedToGallery = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedToGallerySuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.exportFailed(e.toString());
      });
    }
  }

  Future<void> _shareVideo(BuildContext buttonContext) async {
    final path = _exportedPath;
    if (path == null) return;
    Rect? origin;
    final box = buttonContext.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }
    await widget.exportService.shareVideo(
      path,
      sharePositionOrigin: origin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.exportTitle),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_exportedPath == null && !_isExporting) ...<Widget>[
              Text(
                l10n.resolution,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(l10n.res720p),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(l10n.res480p),
                  ),
                ],
                selected: <bool>{_isHd720},
                onSelectionChanged: (v) {
                  if (v.isNotEmpty) setState(() => _isHd720 = v.first);
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.duration,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <int>[0, 3, 5, 8, 10].map((sec) {
                  final label = sec == 0
                      ? l10n.durationAuto(_autoDuration.toStringAsFixed(1))
                      : l10n.secondsShort(sec);
                  return ChoiceChip(
                    label: Text(label),
                    selected: _selectedDurationOption == sec,
                    onSelected: (_) =>
                        setState(() => _selectedDurationOption = sec),
                  );
                }).toList(),
              ),
              if (widget.config.backgroundType == BackgroundType.video) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  l10n.videoBgFallbackNote,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
            if (_isExporting) ...<Widget>[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _progress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.exportingProgress((_progress * 100).round()),
                textAlign: TextAlign.center,
              ),
            ],
            if (_exportedPath != null) ...<Widget>[
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 44,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.exportSuccess,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _savedToGallery ? null : _saveToGallery,
                icon: Icon(
                  _savedToGallery ? Icons.check_rounded : Icons.download_rounded,
                ),
                label: Text(
                  _savedToGallery
                      ? l10n.savedToGallerySuccess
                      : l10n.saveToGallery,
                ),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (btnCtx) => OutlinedButton.icon(
                  onPressed: () => _shareVideo(btnCtx),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(l10n.shareVideo),
                ),
              ),
            ],
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        ),
      ),
      actions: <Widget>[
        if (_isExporting)
          TextButton(
            onPressed: () {
              setState(() {
                _isCancelled = true;
              });
            },
            child: Text(l10n.cancel),
          )
        else ...<Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          if (_exportedPath == null)
            FilledButton(
              onPressed: _startExport,
              child: Text(l10n.startExport),
            ),
        ],
      ],
    );
  }
}
