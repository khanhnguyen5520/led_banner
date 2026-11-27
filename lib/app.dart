import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/services/audio_service.dart';
import 'data/services/brightness_service.dart';
import 'data/services/video_export_service.dart';
import 'data/services/wakelock_service.dart';
import 'domain/models/app_settings.dart';
import 'l10n/app_localizations.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/editor/view_models/editor_view_model.dart';
import 'ui/features/editor/views/editor_screen.dart';

/// Root Material application configured with adaptive light/dark studio theme and localization.
class LedBannerApp extends StatelessWidget {
  const LedBannerApp({
    super.key,
    required this.viewModel,
    required this.audioService,
    required this.brightnessService,
    required this.wakelockService,
    required this.videoExportService,
  });

  final EditorViewModel viewModel;
  final AudioService audioService;
  final BrightnessService brightnessService;
  final WakelockService wakelockService;
  final VideoExportService videoExportService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LED Banner',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: switch (viewModel.settings.themeMode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
          },
          locale: Locale(viewModel.settings.localeCode),
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditorScreen(
            viewModel: viewModel,
            audioService: audioService,
            brightnessService: brightnessService,
            wakelockService: wakelockService,
            videoExportService: videoExportService,
          ),
        );
      },
    );
  }
}
