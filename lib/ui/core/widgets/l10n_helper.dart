import '../../../domain/models/banner_config.dart';
import '../../../l10n/app_localizations.dart';

/// Maps domain preset/theme/track/template IDs to localized display labels.
abstract final class L10nHelper {
  static String themeCategoryLabel(
    AppLocalizations l10n,
    ThemeCategory category,
  ) {
    return switch (category) {
      ThemeCategory.general => l10n.catGeneral,
      ThemeCategory.concert => l10n.catConcert,
      ThemeCategory.birthday => l10n.catBirthday,
      ThemeCategory.holiday => l10n.catHoliday,
    };
  }

  static String themePresetLabel(AppLocalizations l10n, ThemePresetId id) {
    return switch (id) {
      ThemePresetId.neonGrid => l10n.themeNeonGrid,
      ThemePresetId.starfield => l10n.themeStarfield,
      ThemePresetId.auroraWave => l10n.themeAurora,
      ThemePresetId.laserParty => l10n.themeLaserParty,
      ThemePresetId.discoSpotlights => l10n.themeDisco,
      ThemePresetId.birthdayConfetti => l10n.themeConfetti,
      ThemePresetId.birthdayBalloons => l10n.themeBalloons,
      ThemePresetId.christmasSnow => l10n.themeSnow,
      ThemePresetId.festiveLights => l10n.themeFestiveLights,
    };
  }

  static String builtInTrackLabel(AppLocalizations l10n, String trackId) {
    return switch (trackId) {
      'concert_pulse' => l10n.trackConcertPulse,
      'birthday_chime' => l10n.trackBirthdayChime,
      'festive_bells' => l10n.trackFestiveBells,
      'neon_chill' => l10n.trackNeonChill,
      _ => trackId,
    };
  }

  static String templateTitle(AppLocalizations l10n, String templateId) {
    return switch (templateId) {
      'concert' => l10n.templateConcert,
      'airport' => l10n.templateAirport,
      'birthday' => l10n.templateBirthday,
      'christmas' => l10n.templateChristmas,
      'shop_sale' => l10n.templateShopSale,
      'party' => l10n.templateParty,
      'taxi' => l10n.templateTaxi,
      'love' => l10n.templateLove,
      _ => templateId,
    };
  }
}
