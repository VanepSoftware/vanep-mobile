import 'package:equatable/equatable.dart';

import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/value_objects/dependent_draft.dart';

enum DependentFormStatus { editing, saving, saved }

sealed class DependentFieldError extends Equatable {
  const DependentFieldError();

  @override
  List<Object?> get props => const [];
}

final class LocalDependentFieldError extends DependentFieldError {
  const LocalDependentFieldError(this.code);

  final DependentDraftError code;

  @override
  List<Object?> get props => [code];
}

final class BackendDependentFieldError extends DependentFieldError {
  const BackendDependentFieldError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

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

Map<DependentField, DependentFieldError> fieldErrorsWithout(
  Map<DependentField, DependentFieldError> errors,
  DependentField field,
) {
  if (!errors.containsKey(field)) return errors;
  final remaining = Map<DependentField, DependentFieldError>.from(errors)
    ..remove(field);
  return remaining;
}
