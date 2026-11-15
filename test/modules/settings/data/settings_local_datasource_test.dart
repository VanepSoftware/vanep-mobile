import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/settings/data/datasources/settings_local_datasource.dart';

import '../settings_mocks.dart';

void main() {
  late MockSettingsBox box;
  late SettingsLocalDataSource dataSource;

  setUp(() {
    box = MockSettingsBox();
    dataSource = SettingsLocalDataSource(box);
  });

  test('reads the stored theme preference', () {
    when(() => box.get(SettingsLocalDataSource.themePreferenceKey))
        .thenReturn('dark');

    expect(dataSource.readThemePreference(), 'dark');
  });

  test('reads null when nothing is stored', () {
    when(() => box.get(SettingsLocalDataSource.themePreferenceKey))
        .thenReturn(null);

    expect(dataSource.readThemePreference(), isNull);
  });

  test('writes the theme preference under its key', () async {
    when(() => box.put(any<dynamic>(), any())).thenAnswer((_) async {});

    await dataSource.saveThemePreference('light');

    verify(() => box.put(SettingsLocalDataSource.themePreferenceKey, 'light'))
        .called(1);
  });
}
