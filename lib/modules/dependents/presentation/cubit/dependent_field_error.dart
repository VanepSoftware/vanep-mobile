import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

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

Map<DependentField, DependentFieldError> fieldErrorsWithout(
  Map<DependentField, DependentFieldError> errors,
  DependentField field,
) {
  if (!errors.containsKey(field)) return errors;
  final remaining = Map<DependentField, DependentFieldError>.from(errors)
    ..remove(field);
  return remaining;
}

Map<DependentField, DependentFieldError> localFieldErrors(
  Map<DependentField, DependentDraftError> errors,
) {
  return errors.map(
    (field, code) => MapEntry(field, LocalDependentFieldError(code)),
  );
}

Map<DependentField, DependentFieldError> backendFieldErrors(
  DependentFailure failure,
) {
  if (failure is! DependentValidationFailure) return const {};
  return failure.messagesByField.map(
    (field, message) => MapEntry(field, BackendDependentFieldError(message)),
  );
}
