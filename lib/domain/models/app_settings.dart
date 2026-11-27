import 'package:flutter/foundation.dart';

/// Supported theme appearance modes for the studio UI.
enum AppThemeMode { system, light, dark }

/// Global application preferences persisted across launches.
@immutable
class AppSettings {
  const AppSettings({
    this.localeCode = 'vi',
    this.themeMode = AppThemeMode.system,
    this.keepScreenAwake = true,
    this.forceLandscape = true,
    this.autoSaveHistory = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawLocale = json['localeCode'] as String? ?? 'vi';
    final rawThemeMode = json['themeMode'] as String?;
    final parsedThemeMode = AppThemeMode.values.cast<AppThemeMode?>().firstWhere(
          (mode) => mode?.name == rawThemeMode,
          orElse: () => AppThemeMode.system,
        ) ??
        AppThemeMode.system;
    return AppSettings(
      localeCode: (rawLocale == 'en' || rawLocale == 'vi') ? rawLocale : 'vi',
      themeMode: parsedThemeMode,
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
      forceLandscape: json['forceLandscape'] as bool? ?? true,
      autoSaveHistory: json['autoSaveHistory'] as bool? ?? true,
    );
  }

  final String localeCode;
  final AppThemeMode themeMode;
  final bool keepScreenAwake;
  final bool forceLandscape;
  final bool autoSaveHistory;

  AppSettings copyWith({
    String? localeCode,
    AppThemeMode? themeMode,
    bool? keepScreenAwake,
    bool? forceLandscape,
    bool? autoSaveHistory,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      themeMode: themeMode ?? this.themeMode,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      forceLandscape: forceLandscape ?? this.forceLandscape,
      autoSaveHistory: autoSaveHistory ?? this.autoSaveHistory,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'localeCode': localeCode,
    'themeMode': themeMode.name,
    'keepScreenAwake': keepScreenAwake,
    'forceLandscape': forceLandscape,
    'autoSaveHistory': autoSaveHistory,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          localeCode == other.localeCode &&
          themeMode == other.themeMode &&
          keepScreenAwake == other.keepScreenAwake &&
          forceLandscape == other.forceLandscape &&
          autoSaveHistory == other.autoSaveHistory;

  @override
  int get hashCode => Object.hash(
    localeCode,
    themeMode,
    keepScreenAwake,
    forceLandscape,
    autoSaveHistory,
  );
}
