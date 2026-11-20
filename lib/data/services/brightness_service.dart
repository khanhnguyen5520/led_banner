import 'package:screen_brightness/screen_brightness.dart';

/// Wraps application-scoped screen brightness controls safely across platforms.
class BrightnessService {
  Future<double> getCurrentBrightness() async {
    try {
      final value = await ScreenBrightness.instance.application;
      return value.clamp(0.05, 1.0);
    } catch (_) {
      return 0.7;
    }
  }

  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(
        value.clamp(0.05, 1.0),
      );
    } catch (_) {
      // Ignore on unsupported platforms or tests.
    }
  }

  Future<void> resetBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {
      // Ignore on unsupported platforms or tests.
    }
  }
}
