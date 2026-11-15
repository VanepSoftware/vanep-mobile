import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

String themePreferenceLabel(AppLocalizations l10n, ThemePreference preference) {
  return switch (preference) {
    ThemePreference.system => l10n.settingsThemeSystem,
    ThemePreference.light => l10n.settingsThemeLight,
    ThemePreference.dark => l10n.settingsThemeDark,
  };
}
