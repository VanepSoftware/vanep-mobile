import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/modules/settings/domain/repositories/theme_preference_repository.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/change_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/get_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/cubit/theme_preference_cubit.dart';
import 'package:vanep_mobile/modules/settings/settings_container.dart';

import 'settings_mocks.dart';

void main() {
  test('registers the repository, use cases and the cubit', () {
    final getIt = GetIt.asNewInstance();

    registerSettingsDependencies(getIt, settingsBox: MockSettingsBox());

    expect(
      getIt<ThemePreferenceRepository>(),
      isA<ThemePreferenceRepository>(),
    );
    expect(getIt<GetThemePreference>(), isA<GetThemePreference>());
    expect(getIt<ChangeThemePreference>(), isA<ChangeThemePreference>());
    expect(
      getIt<ThemePreferenceCubit>(param1: ThemePreference.dark)
          .state
          .preference,
      ThemePreference.dark,
    );
  });
}
