import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/replace_school_days.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_school_days_state.dart';

final SchoolWeek suggestedSchoolWeek = SchoolWeek.fromDays([
  for (final day in [
    Weekday.monday,
    Weekday.tuesday,
    Weekday.wednesday,
    Weekday.thursday,
    Weekday.friday,
  ])
    SchoolDay(weekday: day, shift: fallbackSchoolShift),
]);

class DependentSchoolDaysCubit extends Cubit<DependentSchoolDaysState>
    implements DependentEditorCubit<DependentSchoolDaysState> {
  DependentSchoolDaysCubit({
    required this.dependentToken,
    required this.findSchoolDays,
    required this.replaceSchoolDays,
  }) : super(const DependentSchoolDaysState());

  final String dependentToken;
  final FindSchoolDays findSchoolDays;
  final ReplaceSchoolDays replaceSchoolDays;

  Future<void> load() async {
    emit(const DependentSchoolDaysState());
    final result = await findSchoolDays(dependentToken);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => DependentSchoolDaysState(
        status: DependentSchoolDaysStatus.editing,
        loaded: value,
        week: value.isEmpty ? suggestedSchoolWeek : value,
      ),
      Err(:final error) => DependentSchoolDaysState(
        status: DependentSchoolDaysStatus.loadFailed,
        failure: error,
      ),
    });
  }

  void turnOn(Weekday day) => emitWeek(state.week.turnOn(day));

  void turnOff(Weekday day) => emitWeek(state.week.turnOff(day));

  void changeShift(Weekday day, SchoolShift shift) {
    emitWeek(state.week.changeShift(day, shift));
  }

  void emitWeek(SchoolWeek week) {
    if (state.status != DependentSchoolDaysStatus.editing) return;
    emit(state.copyWith(week: week, clearFailure: true));
  }

  @override
  Future<void> save() async {
    if (!state.canSave) return;
    emit(
      state.copyWith(
        status: DependentSchoolDaysStatus.saving,
        clearFailure: true,
      ),
    );
    final result = await replaceSchoolDays(
      dependentToken: dependentToken,
      week: state.week,
    );
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        status: DependentSchoolDaysStatus.saved,
        loaded: value,
        week: value,
      ),
      Err(:final error) => state.copyWith(
        status: DependentSchoolDaysStatus.editing,
        failure: error,
      ),
    });
  }
}
