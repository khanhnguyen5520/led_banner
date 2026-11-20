import 'package:flutter/material.dart';

import '../../../../../domain/models/banner_config.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/font_helper.dart';
import '../../view_models/editor_view_model.dart';
import 'editor_section_widgets.dart';

/// Tab 1: Scroll direction, speed, typography sizing, style flags, and fonts.
class TextTab extends StatelessWidget {
  const TextTab({super.key, required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = viewModel.config;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: <Widget>[
        EditorSectionTitle(title: l10n.scrollDirection),
        const SizedBox(height: 10),
        SegmentedButton<ScrollDirection>(
          segments: <ButtonSegment<ScrollDirection>>[
            ButtonSegment<ScrollDirection>(
              value: ScrollDirection.left,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(l10n.dirLeft),
            ),
            ButtonSegment<ScrollDirection>(
              value: ScrollDirection.staticText,
              icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
              label: Text(l10n.dirStatic),
            ),
            ButtonSegment<ScrollDirection>(
              value: ScrollDirection.right,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(l10n.dirRight),
            ),
          ],
          selected: <ScrollDirection>{config.direction},
          onSelectionChanged: (values) {
            if (values.isNotEmpty) {
              viewModel.setDirection(values.first);
            }
          },
        ),
        const SizedBox(height: 16),
        EditorSliderTile(
          label: l10n.scrollSpeed,
          valueLabel: '${config.speed.toStringAsFixed(1)}x',
          value: config.speed,
          min: 0.0,
          max: 5.0,
          divisions: 50,
          onChanged: config.direction == ScrollDirection.staticText
              ? null
              : viewModel.setSpeed,
        ),
        EditorSliderTile(
          label: l10n.fontSize,
          valueLabel: '${(config.fontSizeFactor * 100).round()}%',
          value: config.fontSizeFactor,
          min: 0.25,
          max: 0.95,
          divisions: 28,
          onChanged: viewModel.setFontSizeFactor,
        ),
        EditorSliderTile(
          label: l10n.letterSpacing,
          valueLabel: config.letterSpacing.toStringAsFixed(1),
          value: config.letterSpacing,
          min: -2.0,
          max: 16.0,
          divisions: 36,
          onChanged: viewModel.setLetterSpacing,
        ),
        const SizedBox(height: 8),
        EditorSectionTitle(title: l10n.textStyle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: <Widget>[
            FilterChip(
              avatar: const Icon(Icons.format_bold_rounded, size: 18),
              label: Text(l10n.bold),
              selected: config.isBold,
              onSelected: (_) => viewModel.toggleBold(),
            ),
            FilterChip(
              avatar: const Icon(Icons.format_italic_rounded, size: 18),
              label: Text(l10n.italic),
              selected: config.isItalic,
              onSelected: (_) => viewModel.toggleItalic(),
            ),
            FilterChip(
              avatar: const Icon(Icons.flip_rounded, size: 18),
              label: Text(l10n.mirror),
              selected: config.isMirrored,
              onSelected: (_) => viewModel.toggleMirrored(),
            ),
          ],
        ),
        const SizedBox(height: 18),
        EditorSectionTitle(title: l10n.fontFamily),
        const SizedBox(height: 10),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: FontHelper.options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final option = FontHelper.options[index];
              final selected = config.fontId == option.id;
              final displayLabel =
                  option.id == 'default' ? l10n.fontDefault : option.label;
              final previewStyle = FontHelper.resolveTextStyle(
                fontId: option.id,
                fontSize: 18,
                isBold: config.isBold,
                isItalic: config.isItalic,
                letterSpacing: 0.5,
                color: selected ? AppTheme.primaryCyan : AppTheme.textPrimary,
              );

              return InkWell(
                onTap: () => viewModel.setFontId(option.id),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 126,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryCyan.withValues(alpha: 0.14)
                        : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppTheme.primaryCyan
                          : AppTheme.borderSubtle,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Abc 123',
                        style: previewStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: selected
                                  ? AppTheme.primaryCyan
                                  : AppTheme.textMuted,
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
