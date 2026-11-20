import 'package:flutter/foundation.dart';

import 'banner_config.dart';

/// A saved LED banner entry in user history.
@immutable
class BannerHistoryItem {
  const BannerHistoryItem({
    required this.id,
    required this.config,
    required this.createdAt,
    this.isPinned = false,
  });

  factory BannerHistoryItem.fromJson(Map<String, dynamic> json) {
    final configMap = json['config'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final createdRaw = json['createdAt'] as String?;
    return BannerHistoryItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      config: BannerConfig.fromJson(configMap),
      createdAt: createdRaw != null
          ? (DateTime.tryParse(createdRaw) ?? DateTime.now())
          : DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  final String id;
  final BannerConfig config;
  final DateTime createdAt;
  final bool isPinned;

  BannerHistoryItem copyWith({
    String? id,
    BannerConfig? config,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return BannerHistoryItem(
      id: id ?? this.id,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'config': config.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'isPinned': isPinned,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerHistoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          config == other.config &&
          createdAt == other.createdAt &&
          isPinned == other.isPinned;

  @override
  int get hashCode => Object.hash(id, config, createdAt, isPinned);
}
