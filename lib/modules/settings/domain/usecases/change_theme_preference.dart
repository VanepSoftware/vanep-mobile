import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/repositories/theme_preference_repository.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

class ChangeThemePreference {
  const ChangeThemePreference(this.repository);

  final ThemePreferenceRepository repository;

  Future<Result<SettingsFailure, void>> call(ThemePreference preference) {
    return repository.saveThemePreference(preference);
  }
}
