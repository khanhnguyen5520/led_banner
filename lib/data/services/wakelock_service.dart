import 'package:wakelock_plus/wakelock_plus.dart';

/// Wraps `wakelock_plus` to keep the device display awake during LED playback.
class WakelockService {
  Future<void> setEnabled(bool enabled) async {
    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Ignore on unsupported platforms or tests.
    }
  }
}
