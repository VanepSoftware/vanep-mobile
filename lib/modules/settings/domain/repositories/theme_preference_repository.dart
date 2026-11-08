import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

abstract class ThemePreferenceRepository {
  Future<ThemePreference> readThemePreference();

  Future<Result<SettingsFailure, void>> saveThemePreference(
    ThemePreference preference,
  );
}
