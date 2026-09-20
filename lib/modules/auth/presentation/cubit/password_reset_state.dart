import 'package:equatable/equatable.dart';

import '../../domain/value_objects/account_field.dart';
import 'email_code_verification_state.dart';

enum PasswordResetStep { email, code }

enum PasswordResetStatus { editing, submitting, completed }

class PasswordResetState extends Equatable {
  const PasswordResetState({
    required this.email,
    this.step = PasswordResetStep.email,
    this.code = '',
    this.newPassword = '',
    this.status = PasswordResetStatus.editing,
    this.issues = const {},
    this.resendSecondsLeft = 0,
    this.feedback,
  });

  final String email;
  final PasswordResetStep step;
  final String code;
  final String newPassword;
  final PasswordResetStatus status;
  final Map<AccountField, AccountFieldIssue> issues;
  final int resendSecondsLeft;
  final CodeFeedback? feedback;

  bool get isSubmitting => status == PasswordResetStatus.submitting;

  bool get canResend =>
      status == PasswordResetStatus.editing && resendSecondsLeft <= 0;

  PasswordResetState copyWith({
    String? email,
    PasswordResetStep? step,
    String? code,
    String? newPassword,
    PasswordResetStatus? status,
    Map<AccountField, AccountFieldIssue>? issues,
    int? resendSecondsLeft,
    CodeFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      step: step ?? this.step,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      status: status ?? this.status,
      issues: issues ?? this.issues,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }

  @override
  List<Object?> get props => [
    email,
    step,
    code,
    newPassword,
    status,
    issues,
    resendSecondsLeft,
    feedback,
  ];
}
