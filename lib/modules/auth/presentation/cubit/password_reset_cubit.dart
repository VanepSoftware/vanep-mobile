import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/usecases/request_password_reset.dart';
import '../../domain/usecases/reset_password_with_code.dart';
import '../../domain/usecases/verify_email_code.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/signup_form.dart';
import 'code_resend_cooldown.dart';
import 'email_code_verification_state.dart';
import 'password_reset_state.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({
    required this._requestPasswordReset,
    required this._resetPasswordWithCode,
    required this._cooldown,
    required String initialEmail,
  }) : super(PasswordResetState(email: initialEmail));

  final RequestPasswordReset _requestPasswordReset;
  final ResetPasswordWithCode _resetPasswordWithCode;
  final CodeResendCooldown _cooldown;

  void updateEmail(String value) {
    emit(
      state.copyWith(
        email: value,
        issues: accountIssuesWithout(state.issues, AccountField.email),
        clearFeedback: true,
      ),
    );
  }

  void updateCode(String value) {
    final digits = extractDigits(value);
    emit(
      state.copyWith(
        code: digits.length > verificationCodeLength
            ? digits.substring(0, verificationCodeLength)
            : digits,
        issues: accountIssuesWithout(state.issues, AccountField.code),
        clearFeedback: true,
      ),
    );
  }

  void updateNewPassword(String value) {
    emit(
      state.copyWith(
        newPassword: value,
        issues: accountIssuesWithout(state.issues, AccountField.password),
        clearFeedback: true,
      ),
    );
  }

  Future<void> requestCode() async {
    if (state.isSubmitting) return;
    emitSubmitting();
    final result = await _requestPasswordReset(state.email);
    result.fold(showFailure, (_) {
      emit(
        state.copyWith(
          status: PasswordResetStatus.editing,
          step: PasswordResetStep.code,
        ),
      );
      startResendCooldown();
    });
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    emitSubmitting();
    final result = await _requestPasswordReset(state.email);
    result.fold(showFailure, (_) {
      emit(
        state.copyWith(
          status: PasswordResetStatus.editing,
          feedback: const CodeResentFeedback(),
        ),
      );
      startResendCooldown();
    });
  }

  Future<void> resetPassword() async {
    if (state.isSubmitting) return;
    emitSubmitting();
    final result = await _resetPasswordWithCode(
      email: state.email,
      code: state.code,
      newPassword: state.newPassword,
    );
    result.fold(
      showFailure,
      (_) => emit(state.copyWith(status: PasswordResetStatus.completed)),
    );
  }

  void emitSubmitting() {
    emit(
      state.copyWith(
        status: PasswordResetStatus.submitting,
        clearFeedback: true,
      ),
    );
  }

  void startResendCooldown() {
    _cooldown.start((secondsLeft) {
      if (isClosed) return;
      emit(state.copyWith(resendSecondsLeft: secondsLeft));
    });
  }

  void showFailure(AccountFailure failure) {
    if (failure is AccountValidationFailure && failure.issues.isNotEmpty) {
      emit(
        state.copyWith(
          status: PasswordResetStatus.editing,
          issues: failure.issues,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        status: PasswordResetStatus.editing,
        feedback: AccountFailureCodeFeedback(failure),
      ),
    );
  }

  void clearFeedback() {
    if (state.feedback == null) return;
    emit(state.copyWith(clearFeedback: true));
  }

  @override
  Future<void> close() {
    _cooldown.cancel();
    return super.close();
  }
}
