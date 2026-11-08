import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/settings/data/datasources/settings_local_datasource.dart';
import 'package:vanep_mobile/modules/settings/domain/repositories/theme_preference_repository.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/change_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';
import 'package:vanep_mobile/modules/settings/presentation/cubit/theme_preference_cubit.dart';

class MockSettingsBox extends Mock implements Box<String> {}

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

class MockThemePreferenceRepository extends Mock
    implements ThemePreferenceRepository {}

class MockChangeThemePreference extends Mock implements ChangeThemePreference {}

class MockThemePreferenceCubit extends Mock implements ThemePreferenceCubit {}

void registerSettingsFallbacks() {
  registerFallbackValue(ThemePreference.system);
}
