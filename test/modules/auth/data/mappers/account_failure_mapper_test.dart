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

Map<String, Object?> problemDetail(
  int status,
  String code, {
  String detail = 'texto do servidor',
  String? field,
  List<Map<String, String>> errors = const [],
}) => {
  'status': status,
  'title': 'Error',
  'detail': detail,
  'code': code,
  'field': ?field,
  if (errors.isNotEmpty) 'errors': errors,
};

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
    expect(
      mapAccountFailure(
        accountApiError(429, problemDetail(429, 'request.rate_limited')),
      ),
      const TooManyRequestsAccountFailure(),
    );
  });

  test('validation.failed marks every known field as rejected', () {
    final error = accountApiError(
      400,
      problemDetail(
        400,
        'validation.failed',
        errors: const [
          {
            'field': 'name',
            'code': 'auth.signup.name.required',
            'message': 'Informe o nome.',
          },
          {
            'field': 'document',
            'code': 'auth.signup.document.invalid',
            'message': 'CPF inválido.',
          },
          {
            'field': 'driverFieldsComplete',
            'code': 'auth.signup.driver.fields.required',
            'message': 'Informe o valor base.',
          },
          {'field': 'somethingElse', 'message': '?'},
        ],
      ),
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
      mapAccountFailure(
        accountApiError(
          409,
          problemDetail(409, 'auth.signup.email.duplicate', field: 'email'),
        ),
      ),
      const AccountValidationFailure({
        AccountField.email: AccountFieldIssue.duplicate,
      }),
    );
    expect(
      mapAccountFailure(
        accountApiError(
          409,
          problemDetail(
            409,
            'auth.signup.document.duplicate',
            field: 'document',
          ),
        ),
      ),
      const AccountValidationFailure({
        AccountField.document: AccountFieldIssue.duplicate,
      }),
    );
  });

  test(
    'invalid_code and invalid_signup_ticket ProblemDetail codes map cleanly',
    () {
      expect(
        mapAccountFailure(
          accountApiError(400, problemDetail(400, 'auth.error.invalid_code')),
        ),
        const InvalidCodeAccountFailure(),
      );
      expect(
        mapAccountFailure(
          accountApiError(
            400,
            problemDetail(400, 'auth.error.invalid_signup_ticket'),
          ),
        ),
        const InvalidSignupTicketAccountFailure(),
      );
    },
  );

  test('legacy auth codes and unknown bodies map to unexpected', () {
    expect(
      mapAccountFailure(accountApiError(500, '<html>')),
      const UnexpectedAccountFailure('http_500'),
    );
    expect(
      mapAccountFailure(accountApiError(400, problemDetail(400, 'mystery'))),
      const UnexpectedAccountFailure('mystery'),
    );
    expect(
      mapAccountFailure(
        accountApiError(409, problemDetail(409, 'email_duplicate')),
      ),
      const UnexpectedAccountFailure('email_duplicate'),
    );
  });
}
