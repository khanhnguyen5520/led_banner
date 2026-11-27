import 'package:flutter/material.dart';

import '../../../../../domain/models/banner_config.dart';
import '../../../../../domain/models/preset_templates.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/color_picker_sheet.dart';
import '../../../../core/widgets/l10n_helper.dart';
import '../../view_models/editor_view_model.dart';
import 'editor_section_widgets.dart';

/// Tab 4: Solid Color, Categorized Animated Themes, Photo, Video & Dimmer.
class BackgroundTab extends StatefulWidget {
  const BackgroundTab({super.key, required this.viewModel});

  final EditorViewModel viewModel;

  @override
  State<BackgroundTab> createState() => _BackgroundTabState();
}

class _BackgroundTabState extends State<BackgroundTab> {
  ThemeCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final config = widget.viewModel.config;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.paddingOf(context).bottom + 96,
      ),
      children: <Widget>[
        EditorSectionTitle(title: l10n.backgroundMode),
        const SizedBox(height: 10),
        SegmentedButton<BackgroundType>(
          segments: <ButtonSegment<BackgroundType>>[
            ButtonSegment<BackgroundType>(
              value: BackgroundType.solid,
              label: Text(l10n.bgSolid),
            ),
            ButtonSegment<BackgroundType>(
              value: BackgroundType.theme,
              label: Text(l10n.bgTheme),
            ),
            ButtonSegment<BackgroundType>(
              value: BackgroundType.image,
              label: Text(l10n.bgImage),
            ),
            ButtonSegment<BackgroundType>(
              value: BackgroundType.video,
              label: Text(l10n.bgVideo),
            ),
          ],
          selected: <BackgroundType>{config.backgroundType},
          onSelectionChanged: (values) {
            if (values.isNotEmpty) {
              widget.viewModel.setBackgroundType(values.first);
            }
          },
        ),
        const SizedBox(height: 16),
        if (config.backgroundType == BackgroundType.solid) ...<Widget>[
          EditorSectionTitle(title: l10n.backgroundColor),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: PresetTemplates.darkBackgroundSwatches.map((color) {
              final selected = color.toARGB32() == config.backgroundColorValue;
              return GestureDetector(
                onTap: () => widget.viewModel.setBackgroundColor(color.toARGB32()),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? colorScheme.primary : colorScheme.outline,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          ColorPickButton(
            label: l10n.customColor,
            color: Color(config.backgroundColorValue),
            onTap: () async {
              final picked = await showColorPickerSheet(
                context,
                initialColor: Color(config.backgroundColorValue),
                quickSwatches: PresetTemplates.darkBackgroundSwatches,
                title: l10n.backgroundColor,
              );
              if (picked != null) {
                widget.viewModel.setBackgroundColor(picked.toARGB32());
              }
            },
          ),
        ],
        if (config.backgroundType == BackgroundType.theme) ...<Widget>[
          EditorSectionTitle(title: l10n.themeCategory),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l10n.catAll),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...ThemeCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(L10nHelper.themeCategoryLabel(l10n, category)),
                      selected: _selectedCategory == category,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: PresetTemplates.themePresets
                .where(
                  (preset) =>
                      _selectedCategory == null ||
                      preset.category == _selectedCategory,
                )
                .map((preset) {
              final selected = config.themePresetId == preset.id;
              return InkWell(
                onTap: () => widget.viewModel.setThemePreset(preset.id),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        preset.primaryColor,
                        preset.secondaryColor.withValues(alpha: 0.45),
                      ],
                    ),
                    border: Border.all(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      L10nHelper.themePresetLabel(l10n, preset.id),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: <Shadow>[
                          Shadow(color: Colors.black87, blurRadius: 4),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          EditorSliderTile(
            label: l10n.backgroundDim,
            valueLabel: '${(config.backgroundDim * 100).round()}%',
            value: config.backgroundDim,
            min: 0.0,
            max: 0.85,
            divisions: 17,
            onChanged: widget.viewModel.setBackgroundDim,
          ),
        ],
        if (config.backgroundType == BackgroundType.image) ...<Widget>[
          _MediaPickerCard(
            icon: Icons.image_rounded,
            buttonLabel: l10n.pickImage,
            clearLabel: l10n.clearMedia,
            filePath: config.backgroundImagePath,
            selectedFileBuilder: l10n.selectedFile,
            onPick: widget.viewModel.pickBackgroundImage,
            onClear: widget.viewModel.clearBackgroundImage,
          ),
          const SizedBox(height: 14),
          EditorSliderTile(
            label: l10n.backgroundDim,
            valueLabel: '${(config.backgroundDim * 100).round()}%',
            value: config.backgroundDim,
            min: 0.0,
            max: 0.85,
            divisions: 17,
            onChanged: widget.viewModel.setBackgroundDim,
          ),
        ],
        if (config.backgroundType == BackgroundType.video) ...<Widget>[
          _MediaPickerCard(
            icon: Icons.video_library_rounded,
            buttonLabel: l10n.pickVideo,
            clearLabel: l10n.clearMedia,
            filePath: config.backgroundVideoPath,
            selectedFileBuilder: l10n.selectedFile,
            onPick: widget.viewModel.pickBackgroundVideo,
            onClear: widget.viewModel.clearBackgroundVideo,
          ),
          const SizedBox(height: 14),
          EditorSliderTile(
            label: l10n.backgroundDim,
            valueLabel: '${(config.backgroundDim * 100).round()}%',
            value: config.backgroundDim,
            min: 0.0,
            max: 0.85,
            divisions: 17,
            onChanged: widget.viewModel.setBackgroundDim,
          ),
        ],
      ],
    );
  }
}

class _MediaPickerCard extends StatelessWidget {
  const _MediaPickerCard({
    required this.icon,
    required this.buttonLabel,
    required this.clearLabel,
    required this.filePath,
    required this.selectedFileBuilder,
    required this.onPick,
    required this.onClear,
  });

  final IconData icon;
  final String buttonLabel;
  final String clearLabel;
  final String? filePath;
  final String Function(String name) selectedFileBuilder;
  final Future<bool> Function() onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasFile = filePath != null && filePath!.isNotEmpty;
    final fileName =
        hasFile ? filePath!.split(RegExp(r'[/\\]')).last : '';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPick,
                    icon: Icon(icon),
                    label: Text(buttonLabel),
                  ),
                ),
                if (hasFile) ...<Widget>[
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: onClear,
                    child: Text(clearLabel),
                  ),
                ],
              ],
            ),
            if (hasFile) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                selectedFileBuilder(fileName),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
