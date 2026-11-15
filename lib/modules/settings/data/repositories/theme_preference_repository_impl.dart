import 'dart:io';

import 'package:hive_ce/hive_ce.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/settings/data/datasources/settings_local_datasource.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/repositories/theme_preference_repository.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

class ThemePreferenceRepositoryImpl implements ThemePreferenceRepository {
  const ThemePreferenceRepositoryImpl({required this.local});

  final SettingsLocalDataSource local;

  @override
  Future<ThemePreference> readThemePreference() async {
    final storedName = local.readThemePreference();
    return ThemePreference.values.asNameMap()[storedName] ??
        ThemePreference.system;
  }

  @override
  Future<Result<SettingsFailure, void>> saveThemePreference(
    ThemePreference preference,
  ) async {
    try {
      await local.saveThemePreference(preference.name);
      return const Ok(null);
    } on FileSystemException {
      return const Err(SettingsFailure.storageUnavailable);
    } on HiveError {
      return const Err(SettingsFailure.storageUnavailable);
    }
  }
}
