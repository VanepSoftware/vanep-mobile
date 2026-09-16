import 'package:equatable/equatable.dart';

import '../../domain/failures/auth_failure.dart';

enum LoginStatus { editing, submitting, googleSubmitting }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.status = LoginStatus.editing,
    this.failure,
  });

  final String email;
  final String password;
  final LoginStatus status;
  final AuthFailure? failure;

  bool get isSubmitting => status != LoginStatus.editing;

  bool get isSubmittingPassword => status == LoginStatus.submitting;

  bool get isSubmittingGoogle => status == LoginStatus.googleSubmitting;

  bool get canSubmit =>
      email.trim().isNotEmpty && password.isNotEmpty && !isSubmitting;

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    AuthFailure? failure,
    bool clearFailure = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [email, password, status, failure];
}
