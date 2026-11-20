import '../../domain/models/app_settings.dart';
import '../../domain/models/banner_config.dart';
import '../../domain/models/banner_history_item.dart';
import '../services/local_storage_service.dart';

/// Single source of truth for persisted banner config, history, and settings.
class BannerRepository {
  BannerRepository({required this._storageService});

  static const int maxHistoryItems = 50;

  final LocalStorageService _storageService;

  Future<BannerConfig> loadCurrentConfig() async {
    return (await _storageService.loadCurrentConfig()) ?? const BannerConfig();
  }

  Future<void> saveCurrentConfig(BannerConfig config) {
    return _storageService.saveCurrentConfig(config);
  }

  Future<AppSettings> loadSettings() {
    return _storageService.loadSettings();
  }

  Future<void> saveSettings(AppSettings settings) {
    return _storageService.saveSettings(settings);
  }

  Future<List<BannerHistoryItem>> loadHistory() async {
    final items = await _storageService.loadHistory();
    return _sortHistory(items);
  }

  Future<List<BannerHistoryItem>> saveToHistory(
    BannerConfig config,
    List<BannerHistoryItem> currentHistory,
  ) async {
    if (config.text.trim().isEmpty && config.drawings.isEmpty) {
      return currentHistory;
    }

    final existingIndex = currentHistory.indexWhere(
      (item) => item.config == config,
    );

    final List<BannerHistoryItem> updated;
    if (existingIndex != -1) {
      final existing = currentHistory[existingIndex];
      final refreshed = existing.copyWith(createdAt: DateTime.now());
      updated = <BannerHistoryItem>[
        ...currentHistory.take(existingIndex),
        ...currentHistory.skip(existingIndex + 1),
        refreshed,
      ];
    } else {
      final newItem = BannerHistoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        config: config,
        createdAt: DateTime.now(),
      );
      updated = <BannerHistoryItem>[newItem, ...currentHistory];
    }

    final sorted = _sortHistory(updated);
    final trimmed = _trimHistory(sorted);
    await _storageService.saveHistory(trimmed);
    return trimmed;
  }

  Future<List<BannerHistoryItem>> togglePin(
    String id,
    List<BannerHistoryItem> currentHistory,
  ) async {
    final updated = currentHistory
        .map(
          (item) =>
              item.id == id ? item.copyWith(isPinned: !item.isPinned) : item,
        )
        .toList(growable: false);
    final sorted = _sortHistory(updated);
    await _storageService.saveHistory(sorted);
    return sorted;
  }

  Future<List<BannerHistoryItem>> deleteHistoryItem(
    String id,
    List<BannerHistoryItem> currentHistory,
  ) async {
    final updated =
        currentHistory.where((item) => item.id != id).toList(growable: false);
    await _storageService.saveHistory(updated);
    return updated;
  }

  Future<List<BannerHistoryItem>> clearUnpinnedHistory(
    List<BannerHistoryItem> currentHistory,
  ) async {
    final updated =
        currentHistory.where((item) => item.isPinned).toList(growable: false);
    await _storageService.saveHistory(updated);
    return updated;
  }

  List<BannerHistoryItem> _sortHistory(List<BannerHistoryItem> items) {
    final copy = List<BannerHistoryItem>.of(items);
    copy.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return List<BannerHistoryItem>.unmodifiable(copy);
  }

  List<BannerHistoryItem> _trimHistory(List<BannerHistoryItem> sorted) {
    if (sorted.length <= maxHistoryItems) return sorted;
    final pinned = sorted.where((e) => e.isPinned).toList();
    final unpinned = sorted.where((e) => !e.isPinned).toList();
    final remainingSlots = (maxHistoryItems - pinned.length).clamp(0, maxHistoryItems);
    return _sortHistory(<BannerHistoryItem>[
      ...pinned,
      ...unpinned.take(remainingSlots),
    ]);
  }
}
