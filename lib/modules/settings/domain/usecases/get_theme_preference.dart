import 'package:vanep_mobile/modules/settings/domain/repositories/theme_preference_repository.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

class GetThemePreference {
  const GetThemePreference(this.repository);

  final ThemePreferenceRepository repository;

  Future<ThemePreference> call() => repository.readThemePreference();
}
