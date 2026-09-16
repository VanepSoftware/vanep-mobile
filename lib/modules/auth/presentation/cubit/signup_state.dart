import 'package:equatable/equatable.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/signup_form.dart';

enum SignupStatus { editing, submitting, completed }

class SignupState extends Equatable {
  const SignupState({
    required this.form,
    this.status = SignupStatus.editing,
    this.issues = const {},
    this.failure,
  });

  final SignupForm form;
  final SignupStatus status;
  final Map<AccountField, AccountFieldIssue> issues;
  final AccountFailure? failure;

  bool get isSubmitting => status == SignupStatus.submitting;

  bool get isCompleted => status == SignupStatus.completed;

  SignupState copyWith({
    SignupForm? form,
    SignupStatus? status,
    Map<AccountField, AccountFieldIssue>? issues,
    AccountFailure? failure,
    bool clearFailure = false,
  }) {
    return SignupState(
      form: form ?? this.form,
      status: status ?? this.status,
      issues: issues ?? this.issues,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [form, status, issues, failure];
}
