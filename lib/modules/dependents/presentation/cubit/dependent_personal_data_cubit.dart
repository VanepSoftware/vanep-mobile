import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/create_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/update_dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_field_error.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_personal_data_state.dart';

class DependentPersonalDataCubit extends Cubit<DependentPersonalDataState> {
  DependentPersonalDataCubit({
    required this.createDependent,
    required this.updateDependent,
    Dependent? dependent,
  }) : super(
         dependent == null
             ? const DependentPersonalDataState()
             : DependentPersonalDataState.editing(dependent),
       );

  final CreateDependent createDependent;
  final UpdateDependent updateDependent;

  void changeName(String value) {
    emitDraft(state.draft.withName(value), DependentField.name);
  }

  void changeBirthDate(String? value) {
    emitDraft(state.draft.withBirthDate(value), DependentField.birthDate);
  }

  void changeGender(Gender? value) {
    emitDraft(state.draft.withGender(value), DependentField.gender);
  }

  void changeDocument(String value) {
    emitDraft(state.draft.withDocument(value), DependentField.document);
  }

  void emitDraft(DependentDraft draft, DependentField field) {
    emit(
      state.copyWith(
        draft: draft,
        fieldErrors: fieldErrorsWithout(state.fieldErrors, field),
        clearFailure: true,
      ),
    );
  }

  void validateField(DependentField field) {
    final error = validateDependentDraft(state.draft)[field];
    emit(
      state.copyWith(
        fieldErrors: error == null
            ? fieldErrorsWithout(state.fieldErrors, field)
            : {...state.fieldErrors, field: LocalDependentFieldError(error)},
      ),
    );
  }

  Future<void> save() async {
    if (!state.canSave) return;

    final localErrors = validateDependentDraft(state.draft);
    if (localErrors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: localFieldErrors(localErrors)));
      return;
    }

    emit(
      state.copyWith(
        status: DependentEditorStatus.saving,
        fieldErrors: const {},
        clearFailure: true,
      ),
    );

    final snapshot = state.snapshot;
    final result = snapshot == null
        ? await createDependent(state.draft)
        : await updateDependent(snapshot: snapshot, draft: state.draft);
    if (isClosed) return;
    switch (result) {
      case null:
        emit(
          state.copyWith(status: DependentEditorStatus.saved, saved: snapshot),
        );
      case Ok<DependentFailure, Dependent>(:final value):
        emit(state.copyWith(status: DependentEditorStatus.saved, saved: value));
      case Err<DependentFailure, Dependent>(:final error):
        emit(
          state.copyWith(
            status: DependentEditorStatus.editing,
            failure: error,
            fieldErrors: backendFieldErrors(error),
          ),
        );
    }
  }
}
