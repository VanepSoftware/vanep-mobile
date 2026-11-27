import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

AccountFailure mapAccountFailure(DioException error) {
  final problem = ApiProblem.fromDioException(error);
  if (problem.isNetworkFailure) return NetworkAccountFailure(error.message);
  if (problem.matchesCode(ApiErrorCodes.requestRateLimited) ||
      problem.status == 429) {
    return const TooManyRequestsAccountFailure();
  }

  if (error.response?.data is! Map) {
    return UnexpectedAccountFailure('http_${problem.status}');
  }

  return switch (problem.code) {
    ApiErrorCodes.validationFailed => AccountValidationFailure(
      rejectedFieldsOf(problem.errors, fallbackField: problem.field),
    ),
    ApiErrorCodes.authSignupEmailDuplicate => const AccountValidationFailure({
      AccountField.email: AccountFieldIssue.duplicate,
    }),
    ApiErrorCodes.authSignupDocumentDuplicate => const AccountValidationFailure(
      {AccountField.document: AccountFieldIssue.duplicate},
    ),
    ApiErrorCodes.authErrorInvalidCode => const InvalidCodeAccountFailure(),
    ApiErrorCodes.authErrorInvalidSignupTicket =>
      const InvalidSignupTicketAccountFailure(),
    final code => UnexpectedAccountFailure(code ?? 'http_${problem.status}'),
  };
}

Map<AccountField, AccountFieldIssue> rejectedFieldsOf(
  List<ApiProblemFieldError> errors, {
  String? fallbackField,
}) {
  final mapped = {
    for (final error in errors)
      ?AccountField.fromApi(error.field): AccountFieldIssue.rejected,
  };
  if (mapped.isEmpty && fallbackField != null) {
    final parsed = AccountField.fromApi(fallbackField);
    if (parsed != null) return {parsed: AccountFieldIssue.rejected};
  }
  return mapped;
}
