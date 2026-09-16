import 'package:equatable/equatable.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/google_signup_ticket.dart';
import '../../domain/value_objects/signup_form.dart';
import '../../domain/value_objects/user_type.dart';

enum SignupStatus {
  editing,
  submitting,
  completed,
  signedIn,
  registeredWithoutSession,
}

class SignupEntry extends Equatable {
  const SignupEntry({required this.type, this.googleTicket});

  final UserType type;
  final GoogleSignupTicket? googleTicket;

  @override
  List<Object?> get props => [type, googleTicket];
}

class SignupState extends Equatable {
  const SignupState({
    required this.form,
    this.googleTicket,
    this.status = SignupStatus.editing,
    this.issues = const {},
    this.failure,
  });

  final SignupForm form;
  final GoogleSignupTicket? googleTicket;
  final SignupStatus status;
  final Map<AccountField, AccountFieldIssue> issues;
  final AccountFailure? failure;

  bool get isSubmitting => status == SignupStatus.submitting;

  bool get isCompleted => status == SignupStatus.completed;

  bool get isGoogleSignup => googleTicket != null;

  SignupState copyWith({
    SignupForm? form,
    SignupStatus? status,
    Map<AccountField, AccountFieldIssue>? issues,
    AccountFailure? failure,
    bool clearFailure = false,
  }) {
    return SignupState(
      form: form ?? this.form,
      googleTicket: googleTicket,
      status: status ?? this.status,
      issues: issues ?? this.issues,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [form, googleTicket, status, issues, failure];
}
