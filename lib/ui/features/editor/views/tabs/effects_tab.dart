import 'package:flutter/material.dart';

import '../../../../../domain/models/banner_config.dart';
import '../../../../../domain/models/preset_templates.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/color_picker_sheet.dart';
import '../../view_models/editor_view_model.dart';
import 'editor_section_widgets.dart';

/// Tab 2: Solid/Gradient/Rainbow colors, Neon glow/blur, Outline, and Blink effects.
class EffectsTab extends StatelessWidget {
  const EffectsTab({super.key, required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = viewModel.config;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: <Widget>[
        EditorSectionTitle(title: l10n.colorMode),
        const SizedBox(height: 10),
        SegmentedButton<TextColorMode>(
          segments: <ButtonSegment<TextColorMode>>[
            ButtonSegment<TextColorMode>(
              value: TextColorMode.solid,
              label: Text(l10n.modeSolid),
            ),
            ButtonSegment<TextColorMode>(
              value: TextColorMode.gradient,
              label: Text(l10n.modeGradient),
            ),
            ButtonSegment<TextColorMode>(
              value: TextColorMode.rainbow,
              label: Text(l10n.modeRainbow),
            ),
          ],
          selected: <TextColorMode>{config.textColorMode},
          onSelectionChanged: (values) {
            if (values.isNotEmpty) {
              viewModel.setTextColorMode(values.first);
            }
          },
        ),
        if (config.textColorMode != TextColorMode.rainbow) ...<Widget>[
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: PresetTemplates.neonSwatches.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final color = PresetTemplates.neonSwatches[index];
                final selected = color.toARGB32() == config.textColorValue;
                return GestureDetector(
                  onTap: () => viewModel.setTextColor(color.toARGB32()),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.white24,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: ColorPickButton(
                  label: l10n.textColor,
                  color: Color(config.textColorValue),
                  onTap: () async {
                    final picked = await showColorPickerSheet(
                      context,
                      initialColor: Color(config.textColorValue),
                      title: l10n.textColor,
                    );
                    if (picked != null) {
                      viewModel.setTextColor(picked.toARGB32());
                    }
                  },
                ),
              ),
              if (config.textColorMode == TextColorMode.gradient) ...<Widget>[
                const SizedBox(width: 10),
                Expanded(
                  child: ColorPickButton(
                    label: l10n.gradientEndColor,
                    color: Color(config.textGradientEndColorValue),
                    onTap: () async {
                      final picked = await showColorPickerSheet(
                        context,
                        initialColor: Color(config.textGradientEndColorValue),
                        title: l10n.gradientEndColor,
                      );
                      if (picked != null) {
                        viewModel.setTextGradientEndColor(picked.toARGB32());
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 16),
        EditorSliderTile(
          label: l10n.neonGlow,
          valueLabel: config.glowBlur.round().toString(),
          value: config.glowBlur,
          min: 0.0,
          max: 28.0,
          divisions: 28,
          onChanged: viewModel.setGlowBlur,
        ),
        const Divider(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.textOutline,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          value: config.outlineEnabled,
          onChanged: viewModel.setOutlineEnabled,
        ),
        if (config.outlineEnabled) ...<Widget>[
          ColorPickButton(
            label: l10n.outlineColor,
            color: Color(config.outlineColorValue),
            onTap: () async {
              final picked = await showColorPickerSheet(
                context,
                initialColor: Color(config.outlineColorValue),
                title: l10n.outlineColor,
              );
              if (picked != null) {
                viewModel.setOutlineColor(picked.toARGB32());
              }
            },
          ),
          const SizedBox(height: 12),
          EditorSliderTile(
            label: l10n.outlineWidth,
            valueLabel: config.outlineWidth.toStringAsFixed(1),
            value: config.outlineWidth,
            min: 1.0,
            max: 12.0,
            divisions: 22,
            onChanged: viewModel.setOutlineWidth,
          ),
        ],
        const Divider(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.blinkEffect,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          value: config.blinkEnabled,
          onChanged: viewModel.setBlinkEnabled,
        ),
        if (config.blinkEnabled) ...<Widget>[
          const SizedBox(height: 6),
          SegmentedButton<BlinkMode>(
            segments: <ButtonSegment<BlinkMode>>[
              ButtonSegment<BlinkMode>(
                value: BlinkMode.sharp,
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: Text(l10n.blinkSharp),
              ),
              ButtonSegment<BlinkMode>(
                value: BlinkMode.pulse,
                icon: const Icon(Icons.waves_rounded, size: 18),
                label: Text(l10n.blinkPulse),
              ),
            ],
            selected: <BlinkMode>{config.blinkMode},
            onSelectionChanged: (values) {
              if (values.isNotEmpty) {
                viewModel.setBlinkMode(values.first);
              }
            },
          ),
          const SizedBox(height: 12),
          EditorSliderTile(
            label: l10n.blinkSpeed,
            valueLabel: l10n.hzUnit(config.blinkSpeed.toStringAsFixed(1)),
            value: config.blinkSpeed,
            min: 1.0,
            max: 6.0,
            divisions: 20,
            onChanged: viewModel.setBlinkSpeed,
          ),
        ],
      ],
    );
  }
}
