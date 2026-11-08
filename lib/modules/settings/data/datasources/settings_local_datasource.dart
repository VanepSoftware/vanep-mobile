import 'package:hive_ce/hive_ce.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this.settingsBox);

  final Box<String> settingsBox;

  static const String boxName = 'settings';
  static const String themePreferenceKey = 'theme_preference';

  String? readThemePreference() => settingsBox.get(themePreferenceKey);

  Future<void> saveThemePreference(String preferenceName) {
    return settingsBox.put(themePreferenceKey, preferenceName);
  }
}
