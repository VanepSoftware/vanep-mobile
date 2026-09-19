import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/gender.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/usecases/complete_google_signup.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/signup_form.dart';
import '../../domain/value_objects/google_signup_ticket.dart';
import 'signup_state.dart';
import 'start_session.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({
    required this._signUp,
    required this._completeGoogleSignup,
    required this._signInWithGoogle,
    required this._startSession,
    required SignupEntry entry,
  }) : super(
         SignupState(
           form: SignupForm(type: entry.type),
           googleTicket: entry.googleTicket,
         ),
       );

  final SignUp _signUp;
  final CompleteGoogleSignup _completeGoogleSignup;
  final SignInWithGoogle _signInWithGoogle;
  final StartSession _startSession;

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
        issues: accountIssuesWithout(state.issues, editedField),
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: SignupStatus.submitting, clearFailure: true));
    final googleTicket = state.googleTicket;
    if (googleTicket == null) {
      await submitPasswordSignup();
    } else {
      await submitGoogleSignup(googleTicket);
    }
  }

  Future<void> submitPasswordSignup() async {
    final result = await _signUp(state.form);
    result.fold(
      showFailure,
      (_) => emit(state.copyWith(status: SignupStatus.completed)),
    );
  }

  Future<void> submitGoogleSignup(GoogleSignupTicket googleTicket) async {
    final result = await _completeGoogleSignup(
      ticket: googleTicket.ticket,
      form: state.form,
    );
    await result.fold<Future<void>>(
      (failure) async => showFailure(failure),
      (_) => signInWithGoogleAfterSignup(),
    );
  }

  Future<void> signInWithGoogleAfterSignup() async {
    final result = await _signInWithGoogle();
    result.fold(
      (_) =>
          emit(state.copyWith(status: SignupStatus.registeredWithoutSession)),
      (session) {
        emit(state.copyWith(status: SignupStatus.signedIn));
        _startSession(session);
      },
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
