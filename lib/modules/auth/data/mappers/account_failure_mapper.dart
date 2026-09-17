import 'package:dio/dio.dart';

import '../../domain/failures/account_failure.dart';
import '../../domain/value_objects/account_field.dart';
import '../dtos/auth_api_error_dto.dart';

AccountFailure mapAccountFailure(DioException error) {
  final response = error.response;
  if (response == null) return NetworkAccountFailure(error.message);
  if (response.statusCode == 429) return const TooManyRequestsAccountFailure();

  final body = response.data;
  if (body is! Map) {
    return UnexpectedAccountFailure('http_${response.statusCode}');
  }
  final envelope = AuthApiErrorDto.fromJson(Map<String, Object?>.from(body));
  return switch (envelope.code) {
    'validation_error' => AccountValidationFailure(
      rejectedFieldsOf(envelope.errors),
    ),
    'email_duplicate' => const AccountValidationFailure({
      AccountField.email: AccountFieldIssue.duplicate,
    }),
    'document_duplicate' => const AccountValidationFailure({
      AccountField.document: AccountFieldIssue.duplicate,
    }),
    'invalid_code' => const InvalidCodeAccountFailure(),
    'invalid_signup_ticket' => const InvalidSignupTicketAccountFailure(),
    final code => UnexpectedAccountFailure(
      code ?? 'http_${response.statusCode}',
    ),
  };
}

Map<AccountField, AccountFieldIssue> rejectedFieldsOf(
  List<AuthApiFieldErrorDto> errors,
) {
  return {
    for (final error in errors)
      ?AccountField.fromApi(error.field): AccountFieldIssue.rejected,
  };
}
