import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_field_error.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_state.dart';

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
    switch (result) {
      case null || Ok<DependentFailure, Dependent>():
        emit(state.copyWith(status: DependentFormStatus.saved));
      case Err<DependentFailure, Dependent>(error: final failure):
        emit(
          state.copyWith(
            status: DependentFormStatus.editing,
            failure: failure,
            fieldErrors: backendFieldErrors(failure),
          ),
        );
    }
  }

  Future<Result<DependentFailure, Dependent>?> runSave() {
    final snapshot = state.snapshot;
    if (snapshot == null) return createDependent(state.draft);
    return updateDependent(snapshot: snapshot, draft: state.draft);
  }
}
