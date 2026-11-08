import 'package:flutter/material.dart';

import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

ThemeMode themeModeFor(ThemePreference preference) {
  return switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
