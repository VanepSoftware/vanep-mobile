import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/cubit/theme_preference_cubit.dart';

import '../settings_mocks.dart';

void main() {
  late MockChangeThemePreference changeThemePreference;

  setUpAll(registerSettingsFallbacks);

  setUp(() => changeThemePreference = MockChangeThemePreference());

  ThemePreferenceCubit buildCubit({
    ThemePreference initial = ThemePreference.system,
  }) {
    return ThemePreferenceCubit(
      initialPreference: initial,
      changeThemePreference: changeThemePreference,
    );
  }

  test('starts with the preference read at startup', () {
    final cubit = buildCubit(initial: ThemePreference.dark);

    expect(cubit.state, const ThemePreferenceState(ThemePreference.dark));
  });

  blocTest<ThemePreferenceCubit, ThemePreferenceState>(
    'applies the new preference and saves it',
    setUp: () =>
        when(() => changeThemePreference(any()))
            .thenAnswer((_) async => const Ok<SettingsFailure, void>(null)),
    build: buildCubit,
    act: (cubit) => cubit.selectThemePreference(ThemePreference.dark),
    expect: () => [const ThemePreferenceState(ThemePreference.dark)],
    verify: (_) =>
        verify(() => changeThemePreference(ThemePreference.dark)).called(1),
  );

  blocTest<ThemePreferenceCubit, ThemePreferenceState>(
    'keeps the new preference for the session when saving fails',
    setUp: () => when(() => changeThemePreference(any())).thenAnswer(
      (_) async =>
          const Err<SettingsFailure, void>(SettingsFailure.storageUnavailable),
    ),
    build: buildCubit,
    act: (cubit) => cubit.selectThemePreference(ThemePreference.light),
    expect: () => [
      const ThemePreferenceState(ThemePreference.light),
      const ThemePreferenceState(
        ThemePreference.light,
        failure: SettingsFailure.storageUnavailable,
      ),
    ],
  );

  blocTest<ThemePreferenceCubit, ThemePreferenceState>(
    'ignores picking the preference already selected',
    build: () => buildCubit(initial: ThemePreference.dark),
    act: (cubit) => cubit.selectThemePreference(ThemePreference.dark),
    expect: () => <ThemePreferenceState>[],
    verify: (_) => verifyNever(() => changeThemePreference(any())),
  );
}
