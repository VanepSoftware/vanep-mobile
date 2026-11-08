import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/settings/domain/failures/settings_failure.dart';
import 'package:vanep_mobile/modules/settings/domain/usecases/change_theme_preference.dart';
import 'package:vanep_mobile/modules/settings/domain/value_objects/theme_preference.dart';

class ThemePreferenceState extends Equatable {
  const ThemePreferenceState(this.preference, {this.failure});

  final ThemePreference preference;
  final SettingsFailure? failure;

  @override
  List<Object?> get props => [preference, failure];
}

class ThemePreferenceCubit extends Cubit<ThemePreferenceState> {
  ThemePreferenceCubit({
    required ThemePreference initialPreference,
    required this.changeThemePreference,
  }) : super(ThemePreferenceState(initialPreference));

  final ChangeThemePreference changeThemePreference;

  Future<void> selectThemePreference(ThemePreference preference) async {
    if (preference == state.preference) return;
    emit(ThemePreferenceState(preference));
    final result = await changeThemePreference(preference);
    final failure = result.errorOrNull;
    if (failure == null || isClosed) return;
    emit(ThemePreferenceState(preference, failure: failure));
  }
}
