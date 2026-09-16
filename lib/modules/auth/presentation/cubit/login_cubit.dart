import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/usecases/sign_in_with_password.dart';
import 'login_state.dart';
import 'start_session.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this._signInWithPassword, required this._startSession})
    : super(const LoginState());

  final SignInWithPassword _signInWithPassword;
  final StartSession _startSession;

  void updateEmail(String value) {
    emit(state.copyWith(email: value, clearFailure: true));
  }

  void updatePassword(String value) {
    emit(state.copyWith(password: value, clearFailure: true));
  }

  Future<void> submitPassword() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: LoginStatus.submitting, clearFailure: true));
    final result = await _signInWithPassword(
      email: state.email,
      password: state.password,
    );
    result.fold(showFailure, (session) {
      emit(state.copyWith(status: LoginStatus.editing));
      _startSession(session);
    });
  }

  void showFailure(AuthFailure failure) {
    emit(state.copyWith(status: LoginStatus.editing, failure: failure));
  }

  void clearFailure() {
    if (state.failure == null) return;
    emit(state.copyWith(clearFailure: true));
  }
}
