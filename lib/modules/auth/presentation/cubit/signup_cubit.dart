import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/gender.dart';
import '../../domain/value_objects/signup_form.dart';
import '../../domain/value_objects/user_type.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required this._signUp, required UserType type})
    : super(SignupState(form: SignupForm(type: type)));

  final SignUp _signUp;

  void updateName(String value) =>
      updateForm(state.form.copyWith(name: value), AccountField.name);

  void updateEmail(String value) =>
      updateForm(state.form.copyWith(email: value), AccountField.email);

  void updatePassword(String value) =>
      updateForm(state.form.copyWith(password: value), AccountField.password);

  void updateDocument(String value) =>
      updateForm(state.form.copyWith(document: value), AccountField.document);

  void updatePhone(String value) =>
      updateForm(state.form.copyWith(phone: value), AccountField.phone);

  void updateBirthDate(DateTime value) =>
      updateForm(state.form.copyWith(birthDate: value), AccountField.birthDate);

  void updateGender(Gender value) =>
      updateForm(state.form.copyWith(gender: value), AccountField.gender);

  void updateAcceptTerms(bool value) => updateForm(
    state.form.copyWith(acceptTerms: value),
    AccountField.acceptTerms,
  );

  void updateBasePrice(String value) =>
      updateForm(state.form.copyWith(basePrice: value), AccountField.basePrice);

  void updateCnpj(String value) =>
      updateForm(state.form.copyWith(cnpj: value), AccountField.cnpj);

  void updateExperienceYears(String value) => updateForm(
    state.form.copyWith(experienceYears: value),
    AccountField.experienceYears,
  );

  void updateForm(SignupForm form, AccountField editedField) {
    emit(
      state.copyWith(
        form: form,
        issues: issuesWithout(state.issues, editedField),
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: SignupStatus.submitting, clearFailure: true));
    final result = await _signUp(state.form);
    result.fold(
      showFailure,
      (_) => emit(state.copyWith(status: SignupStatus.completed)),
    );
  }

  void showFailure(AccountFailure failure) {
    if (failure is AccountValidationFailure && failure.issues.isNotEmpty) {
      emit(
        state.copyWith(status: SignupStatus.editing, issues: failure.issues),
      );
      return;
    }
    emit(state.copyWith(status: SignupStatus.editing, failure: failure));
  }

  void clearFailure() {
    if (state.failure == null) return;
    emit(state.copyWith(clearFailure: true));
  }
}

Map<AccountField, AccountFieldIssue> issuesWithout(
  Map<AccountField, AccountFieldIssue> issues,
  AccountField field,
) {
  if (!issues.containsKey(field)) return issues;
  return Map<AccountField, AccountFieldIssue>.from(issues)..remove(field);
}
