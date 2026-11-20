import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Result returned when selecting a local audio file.
class PickedAudioFile {
  const PickedAudioFile({required this.path, required this.name});

  final String path;
  final String name;
}

/// Wraps `image_picker` and `file_picker` for selecting photos, videos, and audio.
class MediaPickerService {
  MediaPickerService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickImagePath() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.gallery);
      return file?.path;
    } catch (_) {
      return null;
    }
  }

  Future<String?> pickVideoPath() async {
    try {
      final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
      return file?.path;
    } catch (_) {
      return null;
    }
  }

  Future<PickedAudioFile?> pickAudioFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const <String>['mp3', 'wav', 'm4a', 'aac', 'ogg'],
      );
      if (file == null || file.path == null || file.path!.isEmpty) {
        return null;
      }
      return PickedAudioFile(path: file.path!, name: file.name);
    } catch (_) {
      return null;
    }
  }
}
