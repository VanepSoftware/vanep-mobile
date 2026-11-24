import 'package:dio/dio.dart';

import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/auth_api_error_dto.dart';

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
    'email_duplicate' ||
    'document_duplicate' ||
    'phone_duplicate' => AccountValidationFailure(
      duplicateFieldsOf(envelope.code, envelope.errors),
    ),
    'invalid_code' => const InvalidCodeAccountFailure(),
    'invalid_signup_ticket' => const InvalidSignupTicketAccountFailure(),
    final code => UnexpectedAccountFailure(
      code ?? 'http_${response.statusCode}',
    ),
  };
}

/// The API lists every duplicated field in `errors`; the code names the
/// first one, so it still works if the list is missing.
Map<AccountField, AccountFieldIssue> duplicateFieldsOf(
  String? code,
  List<AuthApiFieldErrorDto> errors,
) {
  final fromErrors = {
    for (final error in errors)
      ?AccountField.fromApi(error.field): AccountFieldIssue.duplicate,
  };
  if (fromErrors.isNotEmpty) return fromErrors;
  final field = switch (code) {
    'email_duplicate' => AccountField.email,
    'document_duplicate' => AccountField.document,
    _ => AccountField.phone,
  };
  return {field: AccountFieldIssue.duplicate};
}

Map<AccountField, AccountFieldIssue> rejectedFieldsOf(
  List<AuthApiFieldErrorDto> errors,
) {
  return {
    for (final error in errors)
      ?AccountField.fromApi(error.field): AccountFieldIssue.rejected,
  };
}
