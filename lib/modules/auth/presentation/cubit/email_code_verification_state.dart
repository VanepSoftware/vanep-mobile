import 'package:equatable/equatable.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/usecases/verify_email_code.dart';

enum EmailCodeVerificationStatus {
  editing,
  verifying,
  resending,
  verified,
  signedIn,
}

sealed class CodeFeedback extends Equatable {
  const CodeFeedback();

  @override
  List<Object?> get props => [];
}

class CodeResentFeedback extends CodeFeedback {
  const CodeResentFeedback();
}

class AccountFailureCodeFeedback extends CodeFeedback {
  const AccountFailureCodeFeedback(this.failure);

  final AccountFailure failure;

  @override
  List<Object?> get props => [failure];
}

class EmailCodeVerificationRequest extends Equatable {
  const EmailCodeVerificationRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class EmailCodeVerificationState extends Equatable {
  const EmailCodeVerificationState({
    required this.email,
    required this.password,
    this.code = '',
    this.status = EmailCodeVerificationStatus.editing,
    this.resendSecondsLeft = 0,
    this.feedback,
  });

  final String email;
  final String password;
  final String code;
  final EmailCodeVerificationStatus status;
  final int resendSecondsLeft;
  final CodeFeedback? feedback;

  bool get isEditing => status == EmailCodeVerificationStatus.editing;

  bool get isVerifying => status == EmailCodeVerificationStatus.verifying;

  bool get canVerify => isEditing && code.length == verificationCodeLength;

  bool get canResend => isEditing && resendSecondsLeft <= 0;

  EmailCodeVerificationState copyWith({
    String? code,
    EmailCodeVerificationStatus? status,
    int? resendSecondsLeft,
    CodeFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return EmailCodeVerificationState(
      email: email,
      password: password,
      code: code ?? this.code,
      status: status ?? this.status,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    code,
    status,
    resendSecondsLeft,
    feedback,
  ];
}
