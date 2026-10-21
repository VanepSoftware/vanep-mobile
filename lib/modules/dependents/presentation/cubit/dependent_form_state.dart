import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_field_error.dart';

enum DependentFormStatus { editing, saving, saved }

class DependentFormState extends Equatable {
  const DependentFormState({
    this.snapshot,
    this.draft = const DependentDraft(),
    this.status = DependentFormStatus.editing,
    this.fieldErrors = const {},
    this.failure,
  });

  factory DependentFormState.editing(Dependent dependent) {
    return DependentFormState(
      snapshot: dependent,
      draft: DependentDraft.fromDependent(dependent),
    );
  }

  final Dependent? snapshot;

  final DependentDraft draft;

  final DependentFormStatus status;

  final Map<DependentField, DependentFieldError> fieldErrors;

  final DependentFailure? failure;

  bool get isCreating => snapshot == null;

  bool get isSaving => status == DependentFormStatus.saving;

  DependentFieldError? errorOf(DependentField field) => fieldErrors[field];

  DependentFormState copyWith({
    DependentDraft? draft,
    DependentFormStatus? status,
    Map<DependentField, DependentFieldError>? fieldErrors,
    DependentFailure? failure,
    bool clearFailure = false,
  }) {
    return DependentFormState(
      snapshot: snapshot,
      draft: draft ?? this.draft,
      status: status ?? this.status,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [snapshot, draft, status, fieldErrors, failure];
}
