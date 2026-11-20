import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:led_banner/app.dart';
import 'package:led_banner/data/repositories/banner_repository.dart';
import 'package:led_banner/data/services/audio_service.dart';
import 'package:led_banner/data/services/brightness_service.dart';
import 'package:led_banner/data/services/local_storage_service.dart';
import 'package:led_banner/data/services/media_picker_service.dart';
import 'package:led_banner/data/services/video_export_service.dart';
import 'package:led_banner/data/services/wakelock_service.dart';
import 'package:led_banner/domain/models/banner_config.dart';
import 'package:led_banner/ui/features/draw/views/drawing_screen.dart';
import 'package:led_banner/ui/features/editor/view_models/editor_view_model.dart';
import 'package:led_banner/ui/features/editor/views/tabs/media_draw_tab.dart';
import 'package:led_banner/ui/features/history/views/history_screen.dart';
import 'package:led_banner/ui/features/player/views/banner_player_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAudioService extends AudioService {
  @override
  Future<void> playConfig(BannerConfig config) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}
}

class _FakeBrightnessService extends BrightnessService {
  double brightness = 0.7;

  @override
  Future<double> getCurrentBrightness() async => brightness;

  @override
  Future<void> setBrightness(double value) async {
    brightness = value;
  }

  @override
  Future<void> resetBrightness() async {}
}

class _FakeWakelockService extends WakelockService {
  bool enabled = false;

  @override
  Future<void> setEnabled(bool enabled) async {
    this.enabled = enabled;
  }
}

class _FakeMediaPickerService extends MediaPickerService {
  @override
  Future<String?> pickImagePath() async => null;

  @override
  Future<String?> pickVideoPath() async => null;

  @override
  Future<PickedAudioFile?> pickAudioFile() async => null;
}

class _FakeVideoExportService extends VideoExportService {
  @override
  bool get isSupportedPlatform => true;

  @override
  Future<String?> exportBannerToMp4({
    required BannerConfig config,
    required int width,
    required int height,
    required double durationSeconds,
    int fps = 30,
    required void Function(double progress) onProgress,
    required bool Function() isCancelled,
  }) async {
    onProgress(0.5);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    onProgress(1.0);
    return '/tmp/fake_banner.mp4';
  }

  @override
  Future<void> saveToGallery(String filePath) async {}

  @override
  Future<void> shareVideo(String filePath, {Rect? sharePositionOrigin}) async {}
}

/// Pumps bounded frames because `LedBannerCanvas` runs a continuous Ticker.
Future<void> pumpFrames(
  WidgetTester tester, {
  int count = 12,
  Duration step = const Duration(milliseconds: 60),
}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(step);
  }
}

Future<void> tapAndPump(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 20));
  await tester.tap(finder);
  await pumpFrames(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<EditorViewModel> createAppHarness(WidgetTester tester) async {
    final storage = LocalStorageService();
    final repository = BannerRepository(storageService: storage);
    final audioService = _FakeAudioService();
    final brightnessService = _FakeBrightnessService();
    final wakelockService = _FakeWakelockService();
    final mediaPickerService = _FakeMediaPickerService();
    final exportService = _FakeVideoExportService();

    final viewModel = EditorViewModel(
      repository: repository,
      audioService: audioService,
      mediaPickerService: mediaPickerService,
    );
    await viewModel.init();

    await tester.pumpWidget(
      LedBannerApp(
        viewModel: viewModel,
        audioService: audioService,
        brightnessService: brightnessService,
        wakelockService: wakelockService,
        videoExportService: exportService,
      ),
    );
    await pumpFrames(tester, count: 4);
    return viewModel;
  }

  testWidgets('editor switches tabs, opens history, drawing, export, and settings',
      (WidgetTester tester) async {
    final viewModel = await createAppHarness(tester);
    addTearDown(viewModel.dispose);

    // Default Vietnamese UI.
    expect(find.text('Bảng Đèn LED'), findsOneWidget);

    // Edit banner message.
    await tester.enterText(find.byType(TextField), 'HELLO CONCERT');
    await pumpFrames(tester, count: 2);
    expect(viewModel.config.text, 'HELLO CONCERT');

    // Switch through all 5 tabs.
    await tapAndPump(tester, find.text('Hiệu ứng'));
    expect(find.text('Chế độ màu chữ'), findsOneWidget);

    await tapAndPump(tester, find.text('Đèn LED'));
    expect(find.text('Chế độ ma trận LED'), findsOneWidget);

    await tapAndPump(tester, find.text('Hình nền'));
    expect(find.text('Loại hình nền'), findsOneWidget);

    await tapAndPump(tester, find.text('Nhạc & Vẽ'));
    expect(find.text('Nhạc nền'), findsOneWidget);

    // Open Drawing Board and apply.
    final drawButton = find.text('Mở bảng vẽ');
    await tester.scrollUntilVisible(
      drawButton,
      120,
      scrollable: find.descendant(
        of: find.byType(MediaDrawTab),
        matching: find.byType(Scrollable),
      ),
    );
    await tapAndPump(tester, drawButton);
    expect(find.byType(DrawingScreen), findsOneWidget);
    await tapAndPump(tester, find.text('Áp dụng'));
    expect(find.byType(DrawingScreen), findsNothing);

    // Open History & Templates screen and apply a template.
    await tapAndPump(tester, find.byIcon(Icons.history_rounded));
    expect(find.byType(HistoryScreen), findsOneWidget);
    await tapAndPump(tester, find.text('Mẫu sẵn'));
    expect(find.text('Cổ vũ Concert'), findsOneWidget);
    await tapAndPump(tester, find.text('Cổ vũ Concert'));
    expect(find.byType(HistoryScreen), findsNothing);
    expect(viewModel.config.text, contains('SARANGHAE'));

    // Open Export MP4 dialog and run mocked export.
    await tapAndPump(tester, find.byIcon(Icons.movie_creation_outlined));
    expect(find.text('Xuất video MP4'), findsOneWidget);
    await tapAndPump(tester, find.text('Bắt đầu xuất MP4'));
    expect(find.text('Đã tạo video xong!'), findsOneWidget);
    await tapAndPump(tester, find.text('Đóng'));

    // Open Settings and change language to English.
    await tapAndPump(tester, find.byIcon(Icons.settings_outlined));
    await tapAndPump(tester, find.text('English'));
    expect(find.text('Settings'), findsOneWidget);
    await tapAndPump(tester, find.text('Done'));
    expect(find.text('LED Banner'), findsOneWidget);
  });

  testWidgets('full-screen player supports touch lock and long-press unlock',
      (WidgetTester tester) async {
    final viewModel = await createAppHarness(tester);
    addTearDown(viewModel.dispose);

    await tapAndPump(tester, find.text('Phát toàn màn hình'));
    expect(find.byType(BannerPlayerScreen), findsOneWidget);

    // Lock touch controls.
    await tapAndPump(tester, find.byIcon(Icons.lock_outline_rounded));
    expect(find.textContaining('Đã khoá cảm ứng'), findsOneWidget);

    // Long-press the lock pill to unlock.
    await tester.longPress(find.textContaining('Đã khoá cảm ứng'));
    await pumpFrames(tester, count: 4);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // Navigate back cleanly.
    await tapAndPump(tester, find.byIcon(Icons.arrow_back_rounded));
    await pumpFrames(tester, count: 10);
    expect(find.byType(BannerPlayerScreen), findsNothing);
  });
}
