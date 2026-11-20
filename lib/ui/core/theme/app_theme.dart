import 'package:flutter/material.dart';

/// Dark studio Material 3 theme tuned for neon LED preview contrast.
abstract final class AppTheme {
  static const Color scaffoldBg = Color(0xFF0B0D14);
  static const Color surfaceCard = Color(0xFF141824);
  static const Color surfaceElevated = Color(0xFF1C2233);
  static const Color borderSubtle = Color(0xFF272F45);
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color secondaryMagenta = Color(0xFFFF2E93);
  static const Color textPrimary = Color(0xFFF3F6FF);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: primaryCyan,
      onPrimary: Color(0xFF04131A),
      secondary: secondaryMagenta,
      onSecondary: Colors.white,
      surface: surfaceCard,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      outline: borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryCyan,
        inactiveTrackColor: surfaceElevated,
        thumbColor: primaryCyan,
        overlayColor: primaryCyan.withValues(alpha: 0.16),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF04131A);
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryCyan;
          }
          return surfaceElevated;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCyan, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primaryCyan.withValues(alpha: 0.2),
        side: const BorderSide(color: borderSubtle),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
