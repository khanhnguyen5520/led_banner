import 'package:flutter/material.dart';

import '../../../../domain/models/banner_config.dart';
import '../../../../domain/models/preset_templates.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/l10n_helper.dart';
import '../../../core/widgets/led_banner_canvas.dart';
import '../../editor/view_models/editor_view_model.dart';

/// Saved History and Curated Templates browser.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final history = viewModel.history;
          final hasUnpinned = history.any((item) => !item.isPinned);

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.historyTitle),
              actions: <Widget>[
                if (hasUnpinned)
                  IconButton(
                    tooltip: l10n.clearHistory,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.clearHistory),
                          content: Text(l10n.clearHistoryConfirm),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.clear),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await viewModel.clearUnpinnedHistory();
                      }
                    },
                    icon: const Icon(Icons.delete_sweep_rounded),
                  ),
              ],
              bottom: TabBar(
                tabs: <Tab>[
                  Tab(text: l10n.tabHistory),
                  Tab(text: l10n.tabTemplates),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                _HistoryListTab(viewModel: viewModel),
                _TemplatesGridTab(viewModel: viewModel),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryListTab extends StatelessWidget {
  const _HistoryListTab({required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final items = viewModel.history;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.history_toggle_off_rounded,
                size: 54,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.emptyHistory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.emptyHistorySubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final config = item.config;
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              viewModel.loadHistoryItem(item);
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 76,
                    child: LedBannerCanvas(
                      config: config,
                      isPlaying: false,
                      enableVideoPlayback: false,
                      forceCenterWhenPaused: true,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          config.text.isEmpty ? '—' : config.text,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: item.isPinned ? l10n.unpinBanner : l10n.pinBanner,
                        onPressed: () => viewModel.togglePinHistory(item.id),
                        icon: Icon(
                          item.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          size: 20,
                          color: item.isPinned
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        onPressed: () => viewModel.deleteHistoryItem(item.id),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: <Widget>[
                      if (config.pixelLedEnabled) _FeaturePill(l10n.badgeLed),
                      if (config.blinkEnabled) _FeaturePill(l10n.badgeBlink),
                      if (config.musicSourceType != MusicSourceType.none)
                        _FeaturePill(l10n.badgeMusic),
                      if (config.drawings.isNotEmpty)
                        _FeaturePill(l10n.badgeDraw),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TemplatesGridTab extends StatelessWidget {
  const _TemplatesGridTab({required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: PresetTemplates.templates.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final template = PresetTemplates.templates[index];
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              viewModel.applyTemplate(template.config);
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 84,
                    child: LedBannerCanvas(
                      config: template.config,
                      isPlaying: false,
                      enableVideoPlayback: false,
                      forceCenterWhenPaused: true,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          L10nHelper.templateTitle(l10n, template.id),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
