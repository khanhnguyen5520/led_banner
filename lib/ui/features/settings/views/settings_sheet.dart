import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../editor/view_models/editor_view_model.dart';

/// Opens the Settings bottom sheet for language, wakelock, orientation, and history.
Future<void> showSettingsSheet(
  BuildContext context,
  EditorViewModel viewModel,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _SettingsSheetContent(viewModel: viewModel),
  );
}

class _SettingsSheetContent extends StatelessWidget {
  const _SettingsSheetContent({required this.viewModel});

  final EditorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final settings = viewModel.settings;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.settingsTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.done),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'vi',
                      label: Text(l10n.langVietnamese),
                    ),
                    ButtonSegment<String>(
                      value: 'en',
                      label: Text(l10n.langEnglish),
                    ),
                  ],
                  selected: <String>{settings.localeCode},
                  onSelectionChanged: (values) {
                    if (values.isNotEmpty) {
                      viewModel.updateSettings(
                        settings.copyWith(localeCode: values.first),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keepScreenAwake),
                  subtitle: Text(
                    l10n.keepScreenAwakeSub,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  value: settings.keepScreenAwake,
                  onChanged: (v) => viewModel.updateSettings(
                    settings.copyWith(keepScreenAwake: v),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.forceLandscape),
                  subtitle: Text(
                    l10n.forceLandscapeSub,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  value: settings.forceLandscape,
                  onChanged: (v) => viewModel.updateSettings(
                    settings.copyWith(forceLandscape: v),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.autoSaveHistory),
                  subtitle: Text(
                    l10n.autoSaveHistorySub,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  value: settings.autoSaveHistory,
                  onChanged: (v) => viewModel.updateSettings(
                    settings.copyWith(autoSaveHistory: v),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
