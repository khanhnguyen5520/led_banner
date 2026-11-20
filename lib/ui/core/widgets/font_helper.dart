import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/banner_config.dart';

/// Descriptor for a selectable banner typeface.
@immutable
class FontOption {
  const FontOption({
    required this.id,
    required this.label,
    required this.googleFontName,
  });

  final String id;
  final String label;
  final String? googleFontName;
}

/// Resolves banner typography via `google_fonts` with safe system fallback.
abstract final class FontHelper {
  static const List<FontOption> options = <FontOption>[
    FontOption(id: 'default', label: 'System', googleFontName: null),
    FontOption(
      id: 'be_vietnam_pro',
      label: 'Be Vietnam Pro',
      googleFontName: 'Be Vietnam Pro',
    ),
    FontOption(
      id: 'montserrat',
      label: 'Montserrat',
      googleFontName: 'Montserrat',
    ),
    FontOption(id: 'oswald', label: 'Oswald', googleFontName: 'Oswald'),
    FontOption(
      id: 'roboto_mono',
      label: 'Roboto Mono',
      googleFontName: 'Roboto Mono',
    ),
    FontOption(
      id: 'jetbrains_mono',
      label: 'JetBrains Mono',
      googleFontName: 'JetBrains Mono',
    ),
    FontOption(id: 'pacifico', label: 'Pacifico', googleFontName: 'Pacifico'),
    FontOption(
      id: 'playfair',
      label: 'Playfair',
      googleFontName: 'Playfair Display',
    ),
    FontOption(id: 'bungee', label: 'Bungee', googleFontName: 'Bungee'),
    FontOption(id: 'vt323', label: 'VT323 Pixel', googleFontName: 'VT323'),
  ];

  static FontOption optionForId(String fontId) {
    for (final option in options) {
      if (option.id == fontId) return option;
    }
    return options.first;
  }

  static TextStyle resolveTextStyle({
    required String fontId,
    required double fontSize,
    required bool isBold,
    required bool isItalic,
    required double letterSpacing,
    Color? color,
  }) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing,
      color: color,
      height: 1.08,
      fontFamilyFallback: const <String>['Roboto', 'sans-serif'],
    );

    final option = optionForId(fontId);
    if (option.googleFontName == null) {
      return baseStyle;
    }

    try {
      return GoogleFonts.getFont(
        option.googleFontName!,
        textStyle: baseStyle,
      );
    } catch (_) {
      return baseStyle;
    }
  }

  static TextStyle resolveFromConfig(BannerConfig config, double fontSize) {
    return resolveTextStyle(
      fontId: config.fontId,
      fontSize: fontSize,
      isBold: config.isBold,
      isItalic: config.isItalic,
      letterSpacing: config.letterSpacing,
    );
  }
}
