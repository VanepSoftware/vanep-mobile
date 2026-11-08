import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/settings/data/repositories/theme_preference_repository_impl.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

import '../settings_mocks.dart';

void main() {
  late MockSettingsLocalDataSource local;
  late ThemePreferenceRepositoryImpl repository;

  setUp(() {
    local = MockSettingsLocalDataSource();
    repository = ThemePreferenceRepositoryImpl(local: local);
  });

  group('readThemePreference', () {
    for (final preference in ThemePreference.values) {
      test('maps "${preference.name}" to $preference', () async {
        when(() => local.readThemePreference()).thenReturn(preference.name);

        expect(await repository.readThemePreference(), preference);
      });
    }

    test('defaults to system when nothing is stored', () async {
      when(() => local.readThemePreference()).thenReturn(null);

      expect(await repository.readThemePreference(), ThemePreference.system);
    });

    test('defaults to system when the stored value is unknown', () async {
      when(() => local.readThemePreference()).thenReturn('sepia');

      expect(await repository.readThemePreference(), ThemePreference.system);
    });
  });

  group('saveThemePreference', () {
    test('stores the preference name', () async {
      when(() => local.saveThemePreference(any())).thenAnswer((_) async {});

      final result = await repository.saveThemePreference(ThemePreference.dark);

      expect(result.isOk, isTrue);
      verify(() => local.saveThemePreference('dark')).called(1);
    });

    test('reports storage failure when the disk write fails', () async {
      when(() => local.saveThemePreference(any()))
          .thenThrow(const FileSystemException('disk full'));

      final result = await repository.saveThemePreference(ThemePreference.dark);

      expect(
        result,
        const Err<SettingsFailure, void>(SettingsFailure.storageUnavailable),
      );
    });

    test('reports storage failure when the box is closed', () async {
      when(() => local.saveThemePreference(any()))
          .thenThrow(HiveError('Box has already been closed.'));

      final result = await repository.saveThemePreference(
        ThemePreference.light,
      );

      expect(result.errorOrNull, SettingsFailure.storageUnavailable);
    });
  });
}
