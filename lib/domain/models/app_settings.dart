import 'package:flutter/foundation.dart';

/// Global application preferences persisted across launches.
@immutable
class AppSettings {
  const AppSettings({
    this.localeCode = 'vi',
    this.keepScreenAwake = true,
    this.forceLandscape = true,
    this.autoSaveHistory = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawLocale = json['localeCode'] as String? ?? 'vi';
    return AppSettings(
      localeCode: (rawLocale == 'en' || rawLocale == 'vi') ? rawLocale : 'vi',
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
      forceLandscape: json['forceLandscape'] as bool? ?? true,
      autoSaveHistory: json['autoSaveHistory'] as bool? ?? true,
    );
  }

  final String localeCode;
  final bool keepScreenAwake;
  final bool forceLandscape;
  final bool autoSaveHistory;

  AppSettings copyWith({
    String? localeCode,
    bool? keepScreenAwake,
    bool? forceLandscape,
    bool? autoSaveHistory,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      forceLandscape: forceLandscape ?? this.forceLandscape,
      autoSaveHistory: autoSaveHistory ?? this.autoSaveHistory,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'localeCode': localeCode,
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
          keepScreenAwake == other.keepScreenAwake &&
          forceLandscape == other.forceLandscape &&
          autoSaveHistory == other.autoSaveHistory;

  @override
  int get hashCode => Object.hash(
    localeCode,
    keepScreenAwake,
    forceLandscape,
    autoSaveHistory,
  );
}
