import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/formatters/theme_preference_label.dart';
import 'package:vanep_mobile/modules/settings/presentation/mappers/theme_mode_mapper.dart';

void main() {
  test('maps each preference to the matching ThemeMode', () {
    expect(themeModeFor(ThemePreference.system), ThemeMode.system);
    expect(themeModeFor(ThemePreference.light), ThemeMode.light);
    expect(themeModeFor(ThemePreference.dark), ThemeMode.dark);
  });

  test('labels each preference from the ARB', () {
    final l10n = AppLocalizationsPt();

    expect(themePreferenceLabel(l10n, ThemePreference.system), 'Sistema');
    expect(themePreferenceLabel(l10n, ThemePreference.light), 'Claro');
    expect(themePreferenceLabel(l10n, ThemePreference.dark), 'Escuro');
  });
}
