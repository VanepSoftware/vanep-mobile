import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_field_error.dart';

class DependentPersonalDataState extends Equatable {
  const DependentPersonalDataState({
    this.snapshot,
    this.draft = const DependentDraft(),
    this.status = DependentEditorStatus.editing,
    this.fieldErrors = const {},
    this.failure,
    this.saved,
  });

  factory DependentPersonalDataState.editing(Dependent dependent) {
    return DependentPersonalDataState(
      snapshot: dependent,
      draft: DependentDraft.fromDependent(dependent),
    );
  }

  final Dependent? snapshot;

  final DependentDraft draft;

  final DependentEditorStatus status;

  final Map<DependentField, DependentFieldError> fieldErrors;

  final DependentFailure? failure;

  final Dependent? saved;

  bool get isCreating => snapshot == null;

  bool get isSaving => status == DependentEditorStatus.saving;

  bool get hasChanges {
    final snapshot = this.snapshot;
    if (snapshot == null) return true;
    return !buildDependentChangesForUpdate(
      draft: draft,
      snapshot: snapshot,
    ).isEmpty;
  }

  bool get canSave => !isSaving && hasChanges;

  DependentFieldError? errorOf(DependentField field) => fieldErrors[field];

  DependentPersonalDataState copyWith({
    DependentDraft? draft,
    DependentEditorStatus? status,
    Map<DependentField, DependentFieldError>? fieldErrors,
    DependentFailure? failure,
    bool clearFailure = false,
    Dependent? saved,
  }) {
    return DependentPersonalDataState(
      snapshot: snapshot,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: clearFailure ? null : failure ?? this.failure,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
    snapshot,
    draft,
    status,
    fieldErrors,
    failure,
    saved,
  ];
}
