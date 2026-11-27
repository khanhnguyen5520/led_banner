import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:led_banner/gen/assets.gen.dart';

import '../../../../data/services/audio_service.dart';
import '../../../../data/services/brightness_service.dart';
import '../../../../data/services/video_export_service.dart';
import '../../../../data/services/wakelock_service.dart';
import '../../../../domain/models/banner_config.dart';
import '../../../../domain/models/preset_templates.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/led_banner_canvas.dart';
import '../../draw/views/drawing_screen.dart';
import '../../export/views/export_video_dialog.dart';
import '../../history/views/history_screen.dart';
import '../../player/views/banner_player_screen.dart';
import '../../settings/views/settings_sheet.dart';
import '../view_models/editor_view_model.dart';
import 'tabs/background_tab.dart';
import 'tabs/effects_tab.dart';
import 'tabs/led_style_tab.dart';
import 'tabs/media_draw_tab.dart';
import 'tabs/text_tab.dart';

/// Main LED Banner Studio workspace with live preview, message input, and 5 tabs.
class EditorScreen extends StatefulWidget {
  const EditorScreen({
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
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.viewModel.config.text);
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.viewModel.selectedTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.viewModel.setSelectedTab(_tabController.index);
      }
    });
    widget.viewModel.addListener(_syncControllerWithViewModel);
  }

  void _syncControllerWithViewModel() {
    final vmText = widget.viewModel.config.text;
    if (_textController.text != vmText) {
      _textController.value = TextEditingValue(
        text: vmText,
        selection: TextSelection.collapsed(offset: vmText.length),
      );
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncControllerWithViewModel);
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openFullScreenPlayer() async {
    await widget.viewModel.stopPreviewMusic();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BannerPlayerScreen(
          config: widget.viewModel.config,
          settings: widget.viewModel.settings,
          audioService: widget.audioService,
          brightnessService: widget.brightnessService,
          wakelockService: widget.wakelockService,
          videoExportService: widget.videoExportService,
          onAutoSave: widget.viewModel.saveCurrentToHistory,
        ),
      ),
    );
  }

  Future<void> _openDrawingBoard() async {
    final result = await Navigator.of(context).push<List<DrawingStroke>>(
      MaterialPageRoute<List<DrawingStroke>>(
        builder: (_) => DrawingScreen(config: widget.viewModel.config),
      ),
    );
    if (result != null) {
      widget.viewModel.setDrawings(result);
    }
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final config = vm.config;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: colorScheme.primary, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.appTitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                tooltip: l10n.historyTooltip,
                onPressed: _openHistory,
                icon: _SvgIcon(Assets.icons.clockFading),
              ),
              IconButton(
                tooltip: l10n.randomizeTooltip,
                onPressed: () {
                  vm.applyRandomStyle();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(l10n.randomStyleApplied),
                        duration: const Duration(milliseconds: 1100),
                      ),
                    );
                },
                icon: _SvgIcon(Assets.icons.dices),
              ),
              IconButton(
                tooltip: l10n.exportTooltip,
                onPressed: () => showExportVideoDialog(
                  context,
                  config: config,
                  exportService: widget.videoExportService,
                ),
                icon: _SvgIcon(Assets.icons.imagePlay),
              ),
              IconButton(
                tooltip: l10n.settingsTooltip,
                onPressed: () => showSettingsSheet(context, vm),
                icon: _SvgIcon(Assets.icons.settings2),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              // Live 16:9 LED Preview Bezel.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 168),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(
                              config.textColorValue,
                            ).withValues(alpha: 0.16),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _openFullScreenPlayer,
                            child: LedBannerCanvas(
                              config: config,
                              isPlaying: vm.isPreviewPlaying,
                              forceCenterWhenPaused: false,
                              borderRadius: BorderRadius.circular(16.5),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Row(
                              children: <Widget>[
                                _PreviewOverlayButton(
                                  icon: Icon(
                                    vm.isPreviewPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                                  tooltip: vm.isPreviewPlaying
                                      ? l10n.pause
                                      : l10n.play,
                                  onPressed: vm.togglePreviewPlaying,
                                ),
                                const SizedBox(width: 6),
                                _PreviewOverlayButton(
                                  icon: _SvgIcon(Assets.icons.pencil, size: 18),
                                  tooltip: l10n.drawShortcut,
                                  onPressed: _openDrawingBoard,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _openFullScreenPlayer,
                              icon: const Icon(
                                Icons.fullscreen_rounded,
                                size: 18,
                              ),
                              label: Text(l10n.playFullScreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Message input + quick emojis.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onChanged: vm.setText,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: l10n.messageHint,
                          prefixIcon: UnconstrainedBox(
                            child: _SvgIcon(
                              Assets.icons.aLargeSmall,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          suffixIcon: config.text.isNotEmpty
                              ? IconButton(
                                  tooltip: l10n.clearText,
                                  onPressed: () {
                                    _textController.clear();
                                    vm.setText('');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _openFullScreenPlayer,
                      child: const Icon(Icons.play_arrow_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: PresetTemplates.quickEmojis.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final emoji = PresetTemplates.quickEmojis[index];
                    return ActionChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 16)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => vm.appendEmoji(emoji),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // 5-Tab Studio Controls.
              Expanded(
                child: Stack(
                  children: <Widget>[
                    TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        TextTab(viewModel: vm),
                        EffectsTab(viewModel: vm),
                        LedStyleTab(viewModel: vm),
                        BackgroundTab(viewModel: vm),
                        MediaDrawTab(
                          viewModel: vm,
                          onOpenDrawingBoard: _openDrawingBoard,
                        ),
                      ],
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.only(bottom: 12),
                        child: _StudioPillTabBar(
                          controller: _tabController,
                          l10n: l10n,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewOverlayButton extends StatelessWidget {
  const _PreviewOverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: IconTheme(
          data: const IconThemeData(color: Colors.white, size: 18),
          child: icon,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _StudioPillTabBar extends StatelessWidget {
  const _StudioPillTabBar({required this.controller, required this.l10n});

  final TabController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final tabItems = <({SvgGenImage icon, String label})>[
      (icon: Assets.icons.aLargeSmall, label: l10n.tabText),
      (icon: Assets.icons.wandSparkles, label: l10n.tabEffects),
      (icon: Assets.icons.lightbulb, label: l10n.tabLedStyle),
      (icon: Assets.icons.image, label: l10n.tabBackground),
      (icon: Assets.icons.music4, label: l10n.tabMediaDraw),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.14),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.72)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.78),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.85),
                width: isDark ? 1 : 1.2,
              ),
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final selectedIndex = controller.index;
                return TabBar(
                  controller: controller,
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  splashBorderRadius: BorderRadius.circular(999),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: isDark
                        ? colorScheme.surface
                        : Colors.white.withValues(alpha: 0.94),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.14)
                          : Colors.white,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.30 : 0.08,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  tabs: List<Widget>.generate(tabItems.length, (index) {
                    final item = tabItems[index];
                    final isSelected = index == selectedIndex;
                    return Tab(
                      height: 54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _SvgIcon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SvgIcon extends StatelessWidget {
  const _SvgIcon(this.asset, {this.size = 22, this.color});

  final SvgGenImage asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return asset.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
