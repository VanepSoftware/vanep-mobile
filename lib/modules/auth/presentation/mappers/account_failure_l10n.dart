import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/account_failure.dart';
import '../../domain/value_objects/account_field.dart';
import '../../domain/value_objects/password_policy.dart';

String accountFailureMessage(AppLocalizations l10n, AccountFailure failure) {
  return switch (failure) {
    AccountValidationFailure() => l10n.accountErrorCheckFields,
    InvalidCodeAccountFailure() => l10n.accountErrorInvalidCode,
    InvalidSignupTicketAccountFailure() => l10n.accountErrorInvalidSignupTicket,
    TooManyRequestsAccountFailure() => l10n.authErrorTooManyRequests,
    NetworkAccountFailure() => l10n.accountErrorNetwork,
    UnexpectedAccountFailure() => l10n.accountErrorUnexpected,
  };
}

String? accountFieldIssueMessageOrNull(
  AppLocalizations l10n,
  Map<AccountField, AccountFieldIssue> issues,
  AccountField field, {
  int passwordMinLength = PasswordPolicy.minLength,
}) {
  final issue = issues[field];
  if (issue == null) return null;
  return accountFieldIssueMessage(
    l10n,
    field,
    issue,
    passwordMinLength: passwordMinLength,
  );
}

String accountFieldIssueMessage(
  AppLocalizations l10n,
  AccountField field,
  AccountFieldIssue issue, {
  int passwordMinLength = PasswordPolicy.minLength,
}) {
  return switch ((field, issue)) {
    (_, AccountFieldIssue.required) => l10n.accountIssueRequired,
    (AccountField.email, AccountFieldIssue.invalid) =>
      l10n.accountIssueEmailInvalid,
    (AccountField.document, AccountFieldIssue.invalid) =>
      l10n.accountIssueDocumentInvalid,
    (AccountField.code, AccountFieldIssue.invalid) =>
      l10n.accountIssueCodeInvalid,
    (_, AccountFieldIssue.invalid) => l10n.accountIssueNumberInvalid,
    (_, AccountFieldIssue.tooShort) => l10n.accountIssuePasswordTooShort(
      passwordMinLength,
    ),
    (_, AccountFieldIssue.missingUppercase) ||
    (
      _,
      AccountFieldIssue.missingSpecialCharacter,
    ) => l10n.accountIssuePasswordWeak,
    (_, AccountFieldIssue.mismatch) => l10n.accountIssuePasswordMismatch,
    (_, AccountFieldIssue.notAccepted) => l10n.accountIssueTermsNotAccepted,
    (_, AccountFieldIssue.notPositive) => l10n.accountIssueBasePriceNotPositive,
    (AccountField.document, AccountFieldIssue.duplicate) =>
      l10n.accountIssueDocumentDuplicate,
    (_, AccountFieldIssue.duplicate) => l10n.accountIssueEmailDuplicate,
    (_, AccountFieldIssue.rejected) => l10n.accountIssueRejected,
  };
}
