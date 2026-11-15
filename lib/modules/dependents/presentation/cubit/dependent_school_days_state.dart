import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor.dart';

enum DependentSchoolDaysStatus { loading, loadFailed, editing, saving, saved }

class DependentSchoolDaysState extends Equatable
    implements DependentEditorState {
  const DependentSchoolDaysState({
    this.status = DependentSchoolDaysStatus.loading,
    this.loaded = const SchoolWeek.empty(),
    this.week = const SchoolWeek.empty(),
    this.failure,
  });

  final DependentSchoolDaysStatus status;

  final SchoolWeek loaded;

  final SchoolWeek week;

  final DependentFailure? failure;

  bool get isLoading => status == DependentSchoolDaysStatus.loading;

  bool get hasLoadFailed => status == DependentSchoolDaysStatus.loadFailed;

  @override
  bool get isSaving => status == DependentSchoolDaysStatus.saving;

  @override
  bool get isSaved => status == DependentSchoolDaysStatus.saved;

  @override
  bool get canSave =>
      status == DependentSchoolDaysStatus.editing && week != loaded;

  DependentSchoolDaysState copyWith({
    DependentSchoolDaysStatus? status,
    SchoolWeek? loaded,
    SchoolWeek? week,
    DependentFailure? failure,
    bool clearFailure = false,
  }) {
    return DependentSchoolDaysState(
      status: status ?? this.status,
      loaded: loaded ?? this.loaded,
      week: week ?? this.week,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, loaded, week, failure];
}
