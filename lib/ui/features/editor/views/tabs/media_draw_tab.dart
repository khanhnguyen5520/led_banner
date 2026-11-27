import 'package:flutter/material.dart';

import '../../../../../domain/models/banner_config.dart';
import '../../../../../domain/models/preset_templates.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/l10n_helper.dart';
import '../../../../core/widgets/led_banner_canvas.dart';
import '../../view_models/editor_view_model.dart';
import 'editor_section_widgets.dart';

/// Tab 5: Background Music, Freehand/Shape Drawing Board shortcut, and Quick Templates.
class MediaDrawTab extends StatelessWidget {
  const MediaDrawTab({
    super.key,
    required this.viewModel,
    required this.onOpenDrawingBoard,
  });

  final EditorViewModel viewModel;
  final VoidCallback onOpenDrawingBoard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final config = viewModel.config;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.paddingOf(context).bottom + 96,
      ),
      children: <Widget>[
        EditorSectionTitle(
          title: l10n.backgroundMusic,
          trailing: config.musicSourceType != MusicSourceType.none
              ? IconButton(
                  onPressed: viewModel.togglePreviewMusic,
                  icon: Icon(
                    viewModel.isPreviewMusicPlaying
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    color: colorScheme.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ChoiceChip(
              avatar: const Icon(Icons.music_off_rounded, size: 16),
              label: Text(l10n.musicNone),
              selected: config.musicSourceType == MusicSourceType.none,
              onSelected: (_) => viewModel.clearMusic(),
            ),
            ...PresetTemplates.builtInTracks.map((track) {
              final selected =
                  config.musicSourceType == MusicSourceType.builtIn &&
                  config.musicIdOrPath == track.assetPath;
              return ChoiceChip(
                avatar: const Icon(Icons.music_note_rounded, size: 16),
                label: Text(L10nHelper.builtInTrackLabel(l10n, track.id)),
                selected: selected,
                onSelected: (_) => viewModel.selectBuiltInTrack(track),
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.folder_open_rounded, size: 16),
              label: Text(
                config.musicSourceType == MusicSourceType.file &&
                        config.musicLabel != null
                    ? config.musicLabel!
                    : l10n.pickAudioFile,
              ),
              onPressed: viewModel.pickCustomMusic,
            ),
          ],
        ),
        if (config.musicSourceType != MusicSourceType.none) ...<Widget>[
          const SizedBox(height: 12),
          EditorSliderTile(
            label: l10n.musicVolume,
            valueLabel: '${(config.musicVolume * 100).round()}%',
            value: config.musicVolume,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: viewModel.setMusicVolume,
          ),
        ],
        const Divider(height: 24),
        EditorSectionTitle(title: l10n.drawingOverlay),
        const SizedBox(height: 10),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.drawingStrokeCount(config.drawings.length),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onOpenDrawingBoard,
                        icon: const Icon(Icons.brush_rounded),
                        label: Text(l10n.openDrawingBoard),
                      ),
                    ),
                    if (config.drawings.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: viewModel.clearDrawings,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: Text(l10n.clearDrawings),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        EditorSectionTitle(title: l10n.quickTemplates),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: PresetTemplates.templates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final template = PresetTemplates.templates[index];
              return InkWell(
                onTap: () => viewModel.applyTemplate(template.config),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 162,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: LedBannerCanvas(
                            config: template.config,
                            isPlaying: false,
                            enableVideoPlayback: false,
                            forceCenterWhenPaused: true,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        L10nHelper.templateTitle(l10n, template.id),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
