import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/preset_templates.dart';
import '../../../l10n/app_localizations.dart';

/// Opens a theme-aware studio color picker bottom sheet with swatches, HSV pad, and HEX input.
Future<Color?> showColorPickerSheet(
  BuildContext context, {
  required Color initialColor,
  List<Color>? quickSwatches,
  String? title,
}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ColorPickerSheet(
      initialColor: initialColor,
      quickSwatches: quickSwatches ?? PresetTemplates.neonSwatches,
      title: title,
    ),
  );
}

class _ColorPickerSheet extends StatefulWidget {
  const _ColorPickerSheet({
    required this.initialColor,
    required this.quickSwatches,
    this.title,
  });

  final Color initialColor;
  final List<Color> quickSwatches;
  final String? title;

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late HSVColor _hsv;
  late final TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(
      text: _colorToHex(widget.initialColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _updateFromHsv(HSVColor next) {
    setState(() {
      _hsv = next;
      _hexController.text = _colorToHex(next.toColor());
    });
  }

  void _updateFromHex(String raw) {
    final cleaned = raw.trim().replaceFirst('#', '');
    if (cleaned.length != 6) return;
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) return;
    final color = Color(0xFF000000 | parsed);
    setState(() {
      _hsv = HSVColor.fromColor(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final currentColor = _hsv.toColor();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.outline, width: 2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: currentColor.withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title ?? l10n.pickColorTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(currentColor),
                  child: Text(l10n.apply),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.presetSwatches,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.quickSwatches.map((swatch) {
                final selected = swatch.toARGB32() == currentColor.toARGB32();
                return GestureDetector(
                  onTap: () => _updateFromHsv(HSVColor.fromColor(swatch)),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: swatch,
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
              }).toList(),
            ),
            const SizedBox(height: 18),
            // 2D Saturation / Value square.
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 160.0;
                return GestureDetector(
                  onPanDown: (d) => _handleSvDrag(d.localPosition, width, height),
                  onPanUpdate: (d) =>
                      _handleSvDrag(d.localPosition, width, height),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: CustomPaint(
                        painter: _SvBoxPainter(hsv: _hsv),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            // Hue slider bar.
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 12,
                activeTrackColor: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
                inactiveTrackColor: colorScheme.surfaceContainerHighest,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: _hsv.hue,
                min: 0,
                max: 360,
                onChanged: (h) => _updateFromHsv(_hsv.withHue(h)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hexController,
              maxLength: 7,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.hexCodeLabel,
                counterText: '',
                prefixIcon: const Icon(Icons.tag),
              ),
              onChanged: _updateFromHex,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSvDrag(Offset pos, double width, double height) {
    final s = (pos.dx / width).clamp(0.0, 1.0);
    final v = (1.0 - (pos.dy / height)).clamp(0.0, 1.0);
    _updateFromHsv(_hsv.withSaturation(s).withValue(v));
  }
}

class _SvBoxPainter extends CustomPainter {
  const _SvBoxPainter({required this.hsv});

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[Colors.white, hueColor],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.transparent, Colors.black],
        ).createShader(rect),
    );

    final thumbPos = Offset(
      hsv.saturation * size.width,
      (1.0 - hsv.value) * size.height,
    );
    canvas.drawCircle(
      thumbPos,
      9,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _SvBoxPainter oldDelegate) =>
      oldDelegate.hsv != hsv;
}
