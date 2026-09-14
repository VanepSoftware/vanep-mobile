import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dependent.dart';
import '../../domain/failures/dependent_failure.dart';
import '../../domain/usecases/create_dependent.dart';
import '../../domain/usecases/update_dependent.dart';
import '../../domain/value_objects/dependent_address_draft.dart';
import '../../domain/value_objects/dependent_draft.dart';
import 'dependent_form_state.dart';

class DependentFormCubit extends Cubit<DependentFormState> {
  DependentFormCubit({
    required this.createDependent,
    required this.updateDependent,
    Dependent? dependent,
  }) : super(
         dependent == null
             ? const DependentFormState()
             : DependentFormState.editing(dependent),
       );

  final CreateDependent createDependent;
  final UpdateDependent updateDependent;

  void changeName(String value) {
    emit(
      state.copyWith(
        draft: state.draft.withName(value),
        fieldErrors: fieldErrorsWithout(state.fieldErrors, DependentField.name),
        clearFailure: true,
      ),
    );
  }

  void changeBirthDate(String? value) {
    emit(
      state.copyWith(
        draft: state.draft.withBirthDate(value),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.birthDate,
        ),
        clearFailure: true,
      ),
    );
  }

  void changeGender(Gender? value) {
    emit(
      state.copyWith(
        draft: state.draft.withGender(value),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.gender,
        ),
        clearFailure: true,
      ),
    );
  }

  void choosePlace({
    required String placeId,
    required String sessionToken,
    required String label,
  }) {
    final current = state.draft.address;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(
          DependentAddressDraft(
            placeId: placeId,
            sessionToken: sessionToken,
            label: label,
            number: current?.number,
            complement: current?.complement,
          ),
        ),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.address,
        ),
        clearFailure: true,
      ),
    );
  }

  void changeAddressNumber(String value) {
    final current = state.draft.address;
    if (current == null) return;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(current.withNumber(value)),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.address,
        ),
        clearFailure: true,
      ),
    );
  }

  void changeAddressComplement(String value) {
    final current = state.draft.address;
    if (current == null) return;
    emit(
      state.copyWith(
        draft: state.draft.withAddress(current.withComplement(value)),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.address,
        ),
        clearFailure: true,
      ),
    );
  }

  void removeAddress() {
    emit(
      state.copyWith(
        draft: state.draft.withAddress(null),
        fieldErrors: fieldErrorsWithout(
          state.fieldErrors,
          DependentField.address,
        ),
        clearFailure: true,
      ),
    );
  }

  Future<void> save() async {
    if (state.isSaving) return;

    final localErrors = validateDependentDraft(state.draft);
    if (localErrors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: localFieldErrors(localErrors)));
      return;
    }

    emit(
      state.copyWith(
        status: DependentFormStatus.saving,
        fieldErrors: const {},
        clearFailure: true,
      ),
    );

    final result = await runSave();
    if (result == null) {
      emit(state.copyWith(status: DependentFormStatus.saved));
      return;
    }
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: DependentFormStatus.editing,
          failure: failure,
          fieldErrors: backendFieldErrors(failure),
        ),
        (_) => state.copyWith(status: DependentFormStatus.saved),
      ),
    );
  }

  Future<Result<DependentFailure, Dependent>?> runSave() {
    final snapshot = state.snapshot;
    if (snapshot == null) return createDependent(state.draft);
    return updateDependent(snapshot: snapshot, draft: state.draft);
  }
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
