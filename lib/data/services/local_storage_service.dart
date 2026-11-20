import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/banner_config.dart';
import '../../domain/models/banner_history_item.dart';

/// Persists banner state, history entries, and preferences in SharedPreferences.
class LocalStorageService {
  LocalStorageService({this._prefs});

  static const String _currentConfigKey = 'led_banner_current_config_v1';
  static const String _historyKey = 'led_banner_history_v1';
  static const String _settingsKey = 'led_banner_settings_v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<BannerConfig?> loadCurrentConfig() async {
    final prefs = await _instance();
    final raw = prefs.getString(_currentConfigKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return BannerConfig.fromJson(decoded);
      }
    } catch (_) {
      // Ignore corrupt stored state and fall back to default.
    }
    return null;
  }

  Future<void> saveCurrentConfig(BannerConfig config) async {
    final prefs = await _instance();
    await prefs.setString(_currentConfigKey, jsonEncode(config.toJson()));
  }

  Future<List<BannerHistoryItem>> loadHistory() async {
    final prefs = await _instance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return <BannerHistoryItem>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(BannerHistoryItem.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      // Ignore corrupt stored history and fall back to empty list.
    }
    return <BannerHistoryItem>[];
  }

  Future<void> saveHistory(List<BannerHistoryItem> items) async {
    final prefs = await _instance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await _instance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppSettings.fromJson(decoded);
      }
    } catch (_) {
      // Ignore corrupt settings and fall back to defaults.
    }
    return const AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _instance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
