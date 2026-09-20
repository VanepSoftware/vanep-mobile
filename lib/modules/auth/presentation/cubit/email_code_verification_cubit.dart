import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/usecases/resend_email_verification_code.dart';
import '../../domain/usecases/sign_in_with_password.dart';
import '../../domain/usecases/verify_email_code.dart';
import '../../domain/value_objects/signup_form.dart';
import 'code_resend_cooldown.dart';
import 'email_code_verification_state.dart';
import 'start_session.dart';

class EmailCodeVerificationCubit extends Cubit<EmailCodeVerificationState> {
  EmailCodeVerificationCubit({
    required this._verifyEmailCode,
    required this._resendCode,
    required this._signInWithPassword,
    required this._startSession,
    required this._cooldown,
    required String email,
    required String password,
    required bool codeAlreadySent,
  }) : super(
         EmailCodeVerificationState(
           email: email,
           password: password,
           codeAlreadySent: codeAlreadySent,
         ),
       );

  final VerifyEmailCode _verifyEmailCode;
  final ResendEmailVerificationCode _resendCode;
  final SignInWithPassword _signInWithPassword;
  final StartSession _startSession;
  final CodeResendCooldown _cooldown;

  void updateCode(String value) {
    final digits = extractDigits(value);
    final code = digits.length > verificationCodeLength
        ? digits.substring(0, verificationCodeLength)
        : digits;
    emit(state.copyWith(code: code, clearFeedback: true));
  }

  Future<void> verify() async {
    if (!state.canVerify) return;
    emit(
      state.copyWith(
        status: EmailCodeVerificationStatus.verifying,
        clearFeedback: true,
      ),
    );
    final result = await _verifyEmailCode(email: state.email, code: state.code);
    if (isClosed) return;
    await result.fold<Future<void>>(
      (failure) async => showFailure(failure),
      (_) => signInAfterVerification(),
    );
  }

  Future<void> signInAfterVerification() async {
    final result = await _signInWithPassword(
      email: state.email,
      password: state.password,
    );
    result.fold(
      (_) {
        if (!isClosed) {
          emit(state.copyWith(status: EmailCodeVerificationStatus.verified));
        }
      },
      (session) {
        if (!isClosed) {
          emit(state.copyWith(status: EmailCodeVerificationStatus.signedIn));
        }
        // The session is already saved by now, so the app must be told even
        // if the user left this screen while the sign-in was in flight.
        _startSession(session);
      },
    );
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    emit(
      state.copyWith(
        status: EmailCodeVerificationStatus.resending,
        clearFeedback: true,
      ),
    );
    final result = await _resendCode(state.email);
    if (isClosed) return;
    result.fold(showFailure, (_) {
      emit(
        state.copyWith(
          status: EmailCodeVerificationStatus.editing,
          feedback: const CodeResentFeedback(),
        ),
      );
      startResendCooldown();
    });
  }

  void startResendCooldown() {
    _cooldown.start((secondsLeft) {
      if (isClosed) return;
      emit(state.copyWith(resendSecondsLeft: secondsLeft));
    });
  }

  void showFailure(AccountFailure failure) {
    emit(
      state.copyWith(
        status: EmailCodeVerificationStatus.editing,
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
