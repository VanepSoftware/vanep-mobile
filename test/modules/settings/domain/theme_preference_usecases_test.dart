import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/change_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/get_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

import '../settings_mocks.dart';

void main() {
  late MockThemePreferenceRepository repository;

  setUpAll(registerSettingsFallbacks);

  setUp(() => repository = MockThemePreferenceRepository());

  test('GetThemePreference reads from the repository', () async {
    when(() => repository.readThemePreference())
        .thenAnswer((_) async => ThemePreference.dark);

    expect(await GetThemePreference(repository)(), ThemePreference.dark);
  });

  test('ChangeThemePreference saves through the repository', () async {
    when(() => repository.saveThemePreference(any()))
        .thenAnswer((_) async => const Ok<SettingsFailure, void>(null));

    final result = await ChangeThemePreference(repository)(
      ThemePreference.light,
    );

    expect(result.isOk, isTrue);
    verify(() => repository.saveThemePreference(ThemePreference.light));
  });
}
