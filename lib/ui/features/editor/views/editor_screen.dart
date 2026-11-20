import 'package:flutter/material.dart';

import '../../../../data/services/audio_service.dart';
import '../../../../data/services/brightness_service.dart';
import '../../../../data/services/video_export_service.dart';
import '../../../../data/services/wakelock_service.dart';
import '../../../../domain/models/banner_config.dart';
import '../../../../domain/models/preset_templates.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
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
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryCyan,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: AppTheme.primaryCyan, blurRadius: 8),
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
                icon: const Icon(Icons.history_rounded),
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
                icon: const Icon(Icons.casino_rounded),
              ),
              IconButton(
                tooltip: l10n.exportTooltip,
                onPressed: () => showExportVideoDialog(
                  context,
                  config: config,
                  exportService: widget.videoExportService,
                ),
                icon: const Icon(Icons.movie_creation_outlined),
              ),
              IconButton(
                tooltip: l10n.settingsTooltip,
                onPressed: () => showSettingsSheet(context, vm),
                icon: const Icon(Icons.settings_outlined),
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
                          color: AppTheme.primaryCyan.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(config.textColorValue)
                                .withValues(alpha: 0.16),
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
                                  icon: vm.isPreviewPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  tooltip: vm.isPreviewPlaying
                                      ? l10n.pause
                                      : l10n.play,
                                  onPressed: vm.togglePreviewPlaying,
                                ),
                                const SizedBox(width: 6),
                                _PreviewOverlayButton(
                                  icon: Icons.brush_rounded,
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
                              icon: const Icon(Icons.fullscreen_rounded, size: 18),
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
                          prefixIcon: const Icon(Icons.text_fields_rounded),
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
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.borderSubtle),
                    bottom: BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppTheme.primaryCyan,
                  labelColor: AppTheme.primaryCyan,
                  unselectedLabelColor: AppTheme.textMuted,
                  tabs: <Tab>[
                    Tab(
                      icon: const Icon(Icons.title_rounded, size: 18),
                      text: l10n.tabText,
                    ),
                    Tab(
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                      text: l10n.tabEffects,
                    ),
                    Tab(
                      icon: const Icon(Icons.blur_on_rounded, size: 18),
                      text: l10n.tabLedStyle,
                    ),
                    Tab(
                      icon: const Icon(Icons.wallpaper_rounded, size: 18),
                      text: l10n.tabBackground,
                    ),
                    Tab(
                      icon: const Icon(Icons.music_note_rounded, size: 18),
                      text: l10n.tabMediaDraw,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
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

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white24),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
