import 'package:equatable/equatable.dart';

import '../value_objects/account_field.dart';

sealed class AccountFailure extends Equatable {
  const AccountFailure();

  @override
  List<Object?> get props => [];
}

class AccountValidationFailure extends AccountFailure {
  const AccountValidationFailure(this.issues);

  final Map<AccountField, AccountFieldIssue> issues;

  @override
  List<Object?> get props => [issues];
}

class InvalidCodeAccountFailure extends AccountFailure {
  const InvalidCodeAccountFailure();
}

class InvalidSignupTicketAccountFailure extends AccountFailure {
  const InvalidSignupTicketAccountFailure();
}

class TooManyRequestsAccountFailure extends AccountFailure {
  const TooManyRequestsAccountFailure();
}

class NetworkAccountFailure extends AccountFailure {
  const NetworkAccountFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class UnexpectedAccountFailure extends AccountFailure {
  const UnexpectedAccountFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}
