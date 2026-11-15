import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:vanep_mobile/modules/settings/data/datasources/settings_local_datasource.dart';
import 'package:vanep_mobile/modules/settings/data/repositories/theme_preference_repository_impl.dart';
import 'package:vanep_mobile/modules/settings/domain/repositories/theme_preference_repository.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/change_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/get_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/cubit/theme_preference_cubit.dart';

void registerSettingsDependencies(
  GetIt getIt, {
  required Box<String> settingsBox,
}) {
  getIt
    ..registerSingleton<SettingsLocalDataSource>(
      SettingsLocalDataSource(settingsBox),
    )
    ..registerSingleton<ThemePreferenceRepository>(
      ThemePreferenceRepositoryImpl(local: getIt<SettingsLocalDataSource>()),
    )
    ..registerFactory<GetThemePreference>(
      () => GetThemePreference(getIt<ThemePreferenceRepository>()),
    )
    ..registerFactory<ChangeThemePreference>(
      () => ChangeThemePreference(getIt<ThemePreferenceRepository>()),
    )
    ..registerFactoryParam<ThemePreferenceCubit, ThemePreference, void>(
      (initialPreference, _) => ThemePreferenceCubit(
        initialPreference: initialPreference,
        changeThemePreference: getIt<ChangeThemePreference>(),
      ),
    );
}
