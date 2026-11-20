import 'package:flutter/material.dart';

import 'app.dart';
import 'data/repositories/banner_repository.dart';
import 'data/services/audio_service.dart';
import 'data/services/brightness_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/media_picker_service.dart';
import 'data/services/video_export_service.dart';
import 'data/services/wakelock_service.dart';
import 'ui/features/editor/view_models/editor_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = LocalStorageService();
  final repository = BannerRepository(storageService: storageService);
  final audioService = AudioService();
  final brightnessService = BrightnessService();
  final wakelockService = WakelockService();
  final mediaPickerService = MediaPickerService();
  final videoExportService = VideoExportService();

  final viewModel = EditorViewModel(
    repository: repository,
    audioService: audioService,
    mediaPickerService: mediaPickerService,
  );
  await viewModel.init();

  runApp(
    LedBannerApp(
      viewModel: viewModel,
      audioService: audioService,
      brightnessService: brightnessService,
      wakelockService: wakelockService,
      videoExportService: videoExportService,
    ),
  );
}
