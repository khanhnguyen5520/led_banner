import 'package:flutter/material.dart';

import '../../../../../domain/models/banner_config.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../view_models/editor_view_model.dart';
import 'editor_section_widgets.dart';

/// Tab 3: Pixel LED Dot-Matrix mode, bulb shape, dot size, and grille contrast.
class LedStyleTab extends StatelessWidget {
  const LedStyleTab({super.key, required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final config = viewModel.config;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.paddingOf(context).bottom + 96,
      ),
      children: <Widget>[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.pixelLedMode,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            l10n.pixelLedSubtitle,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          value: config.pixelLedEnabled,
          onChanged: viewModel.setPixelLedEnabled,
        ),
        const SizedBox(height: 12),
        EditorSectionTitle(title: l10n.dotShape),
        const SizedBox(height: 10),
        Row(
          children: LedDotShape.values.map((shape) {
            final selected = config.ledDotShape == shape;
            final label = switch (shape) {
              LedDotShape.circle => l10n.shapeCircle,
              LedDotShape.square => l10n.shapeSquare,
              LedDotShape.roundedSquare => l10n.shapeRounded,
              LedDotShape.diamond => l10n.shapeDiamond,
            };
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: config.pixelLedEnabled
                      ? () => viewModel.setLedDotShape(shape)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: config.pixelLedEnabled ? 1.0 : 0.45,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.primary.withValues(alpha: 0.14)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CustomPaint(
                              painter: _DotShapeIconPainter(
                                shape: shape,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        EditorSliderTile(
          label: l10n.dotSize,
          valueLabel: '${config.ledDotPitch.round()} px',
          value: config.ledDotPitch,
          min: 6.0,
          max: 22.0,
          divisions: 16,
          onChanged: config.pixelLedEnabled ? viewModel.setLedDotPitch : null,
        ),
        EditorSliderTile(
          label: l10n.grilleOpacity,
          valueLabel: '${(config.ledGrilleOpacity * 100).round()}%',
          value: config.ledGrilleOpacity,
          min: 0.35,
          max: 1.0,
          divisions: 26,
          onChanged:
              config.pixelLedEnabled ? viewModel.setLedGrilleOpacity : null,
        ),
      ],
    );
  }
}

class _DotShapeIconPainter extends CustomPainter {
  const _DotShapeIconPainter({required this.shape, required this.color});

  final LedDotShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.36;

    switch (shape) {
      case LedDotShape.circle:
        canvas.drawCircle(center, r, paint);
        break;
      case LedDotShape.square:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: r * 1.9, height: r * 1.9),
          paint,
        );
        break;
      case LedDotShape.roundedSquare:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: r * 1.9, height: r * 1.9),
            const Radius.circular(5),
          ),
          paint,
        );
        break;
      case LedDotShape.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - r * 1.1)
          ..lineTo(center.dx + r * 1.1, center.dy)
          ..lineTo(center.dx, center.dy + r * 1.1)
          ..lineTo(center.dx - r * 1.1, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DotShapeIconPainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color;
}
