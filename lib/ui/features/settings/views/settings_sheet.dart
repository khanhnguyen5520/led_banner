import 'package:flutter/material.dart';

import '../../../../domain/models/app_settings.dart';
import '../../../../l10n/app_localizations.dart';
import '../../editor/view_models/editor_view_model.dart';

/// Opens the Settings bottom sheet for language, theme, wakelock, orientation, and history.
Future<void> showSettingsSheet(
  BuildContext context,
  EditorViewModel viewModel,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _SettingsSheetContent(viewModel: viewModel),
  );
}

class _SettingsSheetContent extends StatefulWidget {
  const _SettingsSheetContent({required this.viewModel});

  final EditorViewModel viewModel;

  @override
  State<_SettingsSheetContent> createState() => _SettingsSheetContentState();
}

class _SettingsSheetContentState extends State<_SettingsSheetContent> {
  bool _isLoading = false;

  Future<void> _applySettings(AppSettings next) async {
    if (_isLoading || next == widget.viewModel.settings) return;
    setState(() => _isLoading = true);
    try {
      await widget.viewModel.updateSettings(next);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final colorScheme = Theme.of(context).colorScheme;
        final settings = widget.viewModel.settings;

        return PopScope(
          canPop: !_isLoading,
          child: Stack(
            children: <Widget>[
              AbsorbPointer(
                absorbing: _isLoading,
                child: SafeArea(
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
                              color: colorScheme.outline,
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.language,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                              _applySettings(
                                settings.copyWith(localeCode: values.first),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.themeMode,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<AppThemeMode>(
                          showSelectedIcon: false,
                          segments: <ButtonSegment<AppThemeMode>>[
                            ButtonSegment<AppThemeMode>(
                              value: AppThemeMode.system,
                              icon: const Icon(
                                Icons.brightness_auto_rounded,
                                size: 17,
                              ),
                              label: Text(l10n.themeSystem),
                            ),
                            ButtonSegment<AppThemeMode>(
                              value: AppThemeMode.light,
                              icon: const Icon(
                                Icons.light_mode_rounded,
                                size: 17,
                              ),
                              label: Text(l10n.themeLight),
                            ),
                            ButtonSegment<AppThemeMode>(
                              value: AppThemeMode.dark,
                              icon: const Icon(
                                Icons.dark_mode_rounded,
                                size: 17,
                              ),
                              label: Text(l10n.themeDark),
                            ),
                          ],
                          selected: <AppThemeMode>{settings.themeMode},
                          onSelectionChanged: (values) {
                            if (values.isNotEmpty) {
                              _applySettings(
                                settings.copyWith(themeMode: values.first),
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
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          value: settings.keepScreenAwake,
                          onChanged: (v) => _applySettings(
                            settings.copyWith(keepScreenAwake: v),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.forceLandscape),
                          subtitle: Text(
                            l10n.forceLandscapeSub,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          value: settings.forceLandscape,
                          onChanged: (v) => _applySettings(
                            settings.copyWith(forceLandscape: v),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.autoSaveHistory),
                          subtitle: Text(
                            l10n.autoSaveHistorySub,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          value: settings.autoSaveHistory,
                          onChanged: (v) => _applySettings(
                            settings.copyWith(autoSaveHistory: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: ColoredBox(
                      color: colorScheme.scrim.withValues(alpha: 0.28),
                      child: Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(20),
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
