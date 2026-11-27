import 'package:flutter/material.dart';

import '../../../../domain/models/banner_config.dart';
import '../../../../domain/models/preset_templates.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/color_picker_sheet.dart';
import '../../../core/widgets/led_banner_canvas.dart';

/// Interactive freehand & shape drawing studio layered directly over the LED banner.
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key, required this.config});

  final BannerConfig config;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late List<DrawingStroke> _strokes;
  final List<DrawingStroke> _redoStack = <DrawingStroke>[];
  DrawingStroke? _activeStroke;

  DrawingTool _tool = DrawingTool.freehand;
  Color _brushColor = const Color(0xFFFF2E93);
  double _strokeWidth = 6.0;
  bool _glow = true;

  @override
  void initState() {
    super.initState();
    _strokes = List<DrawingStroke>.of(widget.config.drawings);
  }

  DrawingPoint _normalize(Offset localPosition, Size size) {
    final nx = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final ny = (localPosition.dy / size.height).clamp(0.0, 1.0);
    return DrawingPoint(nx, ny);
  }

  void _startStroke(Offset localPosition, Size size) {
    final pt = _normalize(localPosition, size);
    setState(() {
      _redoStack.clear();
      _activeStroke = DrawingStroke(
        tool: _tool,
        points: <DrawingPoint>[pt],
        colorValue: _brushColor.toARGB32(),
        strokeWidth: _strokeWidth,
        glow: _glow,
      );
    });
  }

  void _updateStroke(Offset localPosition, Size size) {
    final active = _activeStroke;
    if (active == null) return;
    final pt = _normalize(localPosition, size);

    setState(() {
      if (active.tool == DrawingTool.freehand) {
        final last = active.points.last;
        final dx = pt.x - last.x;
        final dy = pt.y - last.y;
        if (dx * dx + dy * dy > 0.00004) {
          _activeStroke = active.copyWith(
            points: <DrawingPoint>[...active.points, pt],
          );
        }
      } else {
        _activeStroke = active.copyWith(
          points: <DrawingPoint>[active.points.first, pt],
        );
      }
    });
  }

  void _endStroke() {
    final active = _activeStroke;
    if (active == null) return;
    setState(() {
      _strokes = <DrawingStroke>[..._strokes, active];
      _activeStroke = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      final removed = _strokes.last;
      _strokes = _strokes.sublist(0, _strokes.length - 1);
      _redoStack.add(removed);
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      final restored = _redoStack.removeLast();
      _strokes = <DrawingStroke>[..._strokes, restored];
    });
  }

  void _clearAll() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.addAll(_strokes.reversed);
      _strokes = <DrawingStroke>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final previewDrawings = <DrawingStroke>[
      ..._strokes,
      ?_activeStroke,
    ];
    final previewConfig = widget.config.copyWith(drawings: previewDrawings);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawingTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.undo,
            onPressed: _strokes.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: l10n.redo,
            onPressed: _redoStack.isEmpty ? null : _redo,
            icon: const Icon(Icons.redo_rounded),
          ),
          IconButton(
            tooltip: l10n.clearAll,
            onPressed: _strokes.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_strokes),
              child: Text(l10n.saveDrawing),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child: GestureDetector(
                            onPanStart: (d) =>
                                _startStroke(d.localPosition, size),
                            onPanUpdate: (d) =>
                                _updateStroke(d.localPosition, size),
                            onPanEnd: (_) => _endStroke(),
                            child: LedBannerCanvas(
                              config: previewConfig,
                              isPlaying: false,
                              enableVideoPlayback: false,
                              forceCenterWhenPaused: true,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outline)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _ToolChip(
                          icon: Icons.gesture_rounded,
                          label: l10n.toolFreehand,
                          selected: _tool == DrawingTool.freehand,
                          onTap: () => setState(() => _tool = DrawingTool.freehand),
                        ),
                        _ToolChip(
                          icon: Icons.show_chart_rounded,
                          label: l10n.toolLine,
                          selected: _tool == DrawingTool.line,
                          onTap: () => setState(() => _tool = DrawingTool.line),
                        ),
                        _ToolChip(
                          icon: Icons.crop_square_rounded,
                          label: l10n.toolRect,
                          selected: _tool == DrawingTool.rectangle,
                          onTap: () =>
                              setState(() => _tool = DrawingTool.rectangle),
                        ),
                        _ToolChip(
                          icon: Icons.circle_outlined,
                          label: l10n.toolCircle,
                          selected: _tool == DrawingTool.circle,
                          onTap: () => setState(() => _tool = DrawingTool.circle),
                        ),
                        _ToolChip(
                          icon: Icons.favorite_border_rounded,
                          label: l10n.toolHeart,
                          selected: _tool == DrawingTool.heart,
                          onTap: () => setState(() => _tool = DrawingTool.heart),
                        ),
                        _ToolChip(
                          icon: Icons.star_border_rounded,
                          label: l10n.toolStar,
                          selected: _tool == DrawingTool.star,
                          onTap: () => setState(() => _tool = DrawingTool.star),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: PresetTemplates.neonSwatches.length + 1,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              if (index == PresetTemplates.neonSwatches.length) {
                                return ActionChip(
                                  avatar: const Icon(Icons.colorize_rounded, size: 16),
                                  label: Text(l10n.brushColor),
                                  onPressed: () async {
                                    final picked = await showColorPickerSheet(
                                      context,
                                      initialColor: _brushColor,
                                      title: l10n.brushColor,
                                    );
                                    if (picked != null) {
                                      setState(() => _brushColor = picked);
                                    }
                                  },
                                );
                              }
                              final color = PresetTemplates.neonSwatches[index];
                              final selected =
                                  color.toARGB32() == _brushColor.toARGB32();
                              return GestureDetector(
                                onTap: () => setState(() => _brushColor = color),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? colorScheme.onSurface
                                          : colorScheme.outline,
                                      width: selected ? 2.5 : 1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Text(
                        '${l10n.brushWidth}: ${_strokeWidth.round()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Expanded(
                        child: Slider(
                          value: _strokeWidth,
                          min: 2.0,
                          max: 20.0,
                          divisions: 18,
                          onChanged: (v) => setState(() => _strokeWidth = v),
                        ),
                      ),
                      FilterChip(
                        label: Text(l10n.neonStroke),
                        selected: _glow,
                        onSelected: (v) => setState(() => _glow = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 17),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
