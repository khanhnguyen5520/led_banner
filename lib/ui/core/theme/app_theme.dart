import 'package:flutter/material.dart';

/// Studio Material 3 themes (dark and light) tuned for neon LED preview contrast.
abstract final class AppTheme {
  // Dark studio palette.
  static const Color scaffoldBg = Color(0xFF0B0D14);
  static const Color surfaceCard = Color(0xFF141824);
  static const Color surfaceElevated = Color(0xFF1C2233);
  static const Color borderSubtle = Color(0xFF272F45);
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color secondaryMagenta = Color(0xFFFF2E93);
  static const Color textPrimary = Color(0xFFF3F6FF);
  static const Color textMuted = Color(0xFF94A3B8);

  // Light studio palette.
  static const Color lightScaffoldBg = Color(0xFFF4F6FB);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFE9EEF7);
  static const Color lightBorderSubtle = Color(0xFFD5DCEB);
  static const Color lightPrimary = Color(0xFF0088A3);
  static const Color lightSecondary = Color(0xFFD81B78);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primaryCyan,
          onPrimary: Color(0xFF04131A),
          secondary: secondaryMagenta,
          onSecondary: Colors.white,
          surface: surfaceCard,
          onSurface: textPrimary,
          onSurfaceVariant: textMuted,
          surfaceContainerHighest: surfaceElevated,
          outline: borderSubtle,
        ),
        scaffoldBg: scaffoldBg,
        switchSelectedThumb: const Color(0xFF04131A),
      );

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: lightPrimary,
          onPrimary: Colors.white,
          secondary: lightSecondary,
          onSecondary: Colors.white,
          surface: lightSurfaceCard,
          onSurface: lightTextPrimary,
          onSurfaceVariant: lightTextMuted,
          surfaceContainerHighest: lightSurfaceElevated,
          outline: lightBorderSubtle,
        ),
        scaffoldBg: lightScaffoldBg,
        switchSelectedThumb: Colors.white,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color switchSelectedThumb,
  }) {
    final surface = colorScheme.surface;
    final elevated = colorScheme.surfaceContainerHighest;
    final border = colorScheme.outline;
    final primary = colorScheme.primary;
    final textPrimary = colorScheme.onSurface;
    final textMuted = colorScheme.onSurfaceVariant;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: elevated,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.16),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return switchSelectedThumb;
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return elevated;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        selectedColor: primary.withValues(alpha: 0.2),
        side: BorderSide(color: border),
        labelStyle: TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
