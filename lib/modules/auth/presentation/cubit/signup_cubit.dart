import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/check_signup_duplicates.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/complete_google_signup.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_in_with_google.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_up.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/google_signup_ticket.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_steps.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/start_session.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({
    required this._signUp,
    required this._checkSignupDuplicates,
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
  final CheckSignupDuplicates _checkSignupDuplicates;
  final CompleteGoogleSignup _completeGoogleSignup;
  final SignInWithGoogle _signInWithGoogle;
  final StartSession _startSession;

  void updateName(String value) =>
      updateForm(state.form.copyWith(name: value), AccountField.name);

  void updateEmail(String value) =>
      updateForm(state.form.copyWith(email: value), AccountField.email);

  void updatePassword(String value) =>
      updateForm(state.form.copyWith(password: value), AccountField.password);

  void updatePasswordConfirmation(String value) => updateForm(
    state.form.copyWith(passwordConfirmation: value),
    AccountField.passwordConfirmation,
  );

  void updateDocument(String value) =>
      updateForm(state.form.copyWith(document: value), AccountField.document);

  void updatePhone(String value) =>
      updateForm(state.form.copyWith(phone: value), AccountField.phone);

  void updateBirthDate(DateTime value) =>
      updateForm(state.form.copyWith(birthDate: value), AccountField.birthDate);

  void updateGender(Gender? value) => updateForm(
    state.form.copyWith(gender: value, clearGender: value == null),
    AccountField.gender,
  );

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

  Future<void> nextStep() async {
    if (state.isBusy) return;
    final allIssues = state.form.validate(
      includeCredentials: !state.isGoogleSignup,
    );
    final stepIssues = issuesOfStep(allIssues, state.currentStep);
    if (stepIssues.isNotEmpty) {
      emit(state.copyWith(issues: {...state.issues, ...stepIssues}));
      return;
    }
    if (state.isLastStep) return;
    final duplicateIssues = await findDuplicatesOfStep();
    if (isClosed) return;
    if (duplicateIssues.isNotEmpty) {
      emit(
        state.copyWith(
          status: SignupStatus.editing,
          issues: {...state.issues, ...duplicateIssues},
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: SignupStatus.editing,
        stepIndex: state.stepIndex + 1,
        issues: issuesOutsideStep(state.issues, state.currentStep),
      ),
    );
  }

  /// Duplicates among the fields of the current step. Any other failure lets
  /// the user go on: sign-up checks again and reports it there.
  Future<Map<AccountField, AccountFieldIssue>> findDuplicatesOfStep() async {
    final step = state.currentStep;
    emit(state.copyWith(status: SignupStatus.checking));
    final result = await _checkSignupDuplicates(state.form, step.fields);
    return switch (result) {
      Err(error: AccountValidationFailure(:final issues)) => issuesOfStep(
        issues,
        step,
      ),
      _ => const {},
    };
  }

  void previousStep() {
    if (state.isFirstStep || state.isBusy) return;
    emit(state.copyWith(stepIndex: state.stepIndex - 1));
  }

  Future<void> submit() async {
    if (state.isBusy) return;
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
    if (isClosed) return;
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
    if (isClosed) return;
    await result.fold<Future<void>>(
      (failure) async => showFailure(failure),
      (_) => signInWithGoogleAfterSignup(),
    );
  }

  Future<void> signInWithGoogleAfterSignup() async {
    final result = await _signInWithGoogle();
    result.fold(
      (_) {
        if (!isClosed) {
          emit(state.copyWith(status: SignupStatus.registeredWithoutSession));
        }
      },
      (session) {
        if (!isClosed) emit(state.copyWith(status: SignupStatus.signedIn));
        // The session is already saved by now, so the app must be told even
        // if the user left this screen while the Google sign-in was open.
        _startSession(session);
      },
    );
  }

  void showFailure(AccountFailure failure) {
    if (failure is AccountValidationFailure && failure.issues.isNotEmpty) {
      emit(
        state.copyWith(
          status: SignupStatus.editing,
          issues: failure.issues,
          stepIndex:
              firstStepIndexWithIssues(state.steps, failure.issues) ??
              state.stepIndex,
        ),
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
