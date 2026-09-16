import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/mappers/account_failure_mapper.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

DioException accountApiError(int status, Object? body) {
  final options = RequestOptions(path: '/api/auth/signup/client');
  return DioException(
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

Map<String, Object?> envelope(
  String code, [
  List<Map<String, String>> errors = const [],
]) => {'code': code, 'message': 'texto do servidor', 'errors': errors};

void main() {
  test('no response is a network failure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/api/auth/signup/client'),
      message: 'offline',
    );

    expect(mapAccountFailure(error), const NetworkAccountFailure('offline'));
  });

  test('429 is a too many requests failure', () {
    expect(
      mapAccountFailure(accountApiError(429, 'Muitas tentativas.')),
      const TooManyRequestsAccountFailure(),
    );
  });

  test('validation_error marks every known field as rejected', () {
    final error = accountApiError(
      400,
      envelope('validation_error', [
        {'field': 'name', 'message': 'Informe o nome.'},
        {'field': 'document', 'message': 'CPF inválido.'},
        {'field': 'driverFieldsComplete', 'message': 'Informe o valor base.'},
        {'field': 'somethingElse', 'message': '?'},
      ]),
    );

    expect(
      mapAccountFailure(error),
      const AccountValidationFailure({
        AccountField.name: AccountFieldIssue.rejected,
        AccountField.document: AccountFieldIssue.rejected,
        AccountField.basePrice: AccountFieldIssue.rejected,
      }),
    );
  });

  test('duplicates mark the e-mail or the document', () {
    expect(
      mapAccountFailure(accountApiError(409, envelope('email_duplicate'))),
      const AccountValidationFailure({
        AccountField.email: AccountFieldIssue.duplicate,
      }),
    );
    expect(
      mapAccountFailure(accountApiError(409, envelope('document_duplicate'))),
      const AccountValidationFailure({
        AccountField.document: AccountFieldIssue.duplicate,
      }),
    );
  });

  test('invalid_code and invalid_signup_ticket have their own failures', () {
    expect(
      mapAccountFailure(accountApiError(400, envelope('invalid_code'))),
      const InvalidCodeAccountFailure(),
    );
    expect(
      mapAccountFailure(
        accountApiError(400, envelope('invalid_signup_ticket')),
      ),
      const InvalidSignupTicketAccountFailure(),
    );
  });

  test('an unknown body is unexpected', () {
    expect(
      mapAccountFailure(accountApiError(500, '<html>')),
      const UnexpectedAccountFailure('http_500'),
    );
    expect(
      mapAccountFailure(accountApiError(400, envelope('mystery'))),
      const UnexpectedAccountFailure('mystery'),
    );
  });
}
