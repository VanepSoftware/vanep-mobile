import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/repositories/account_repository_impl.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

import '../../account_fixtures.dart';
import '../auth_data_mocks.dart';

void main() {
  late MockAccountRemoteDataSource remote;
  late AccountRepositoryImpl repository;

  setUpAll(registerAuthDataFallbacks);

  setUp(() {
    remote = MockAccountRemoteDataSource();
    repository = AccountRepositoryImpl(remote: remote);
  });

  test('signUp succeeds when the API accepts the form', () async {
    when(() => remote.signUp(any())).thenAnswer((_) async {});

    final result = await repository.signUp(validClientSignupForm);

    expect(result.isOk, isTrue);
  });

  test('signUp maps the API envelope to a failure', () async {
    final options = RequestOptions(path: '/api/auth/signup/client');
    when(() => remote.signUp(any())).thenThrow(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 409,
          data: {'code': 'email_duplicate', 'message': 'x', 'errors': []},
        ),
      ),
    );

    final result = await repository.signUp(validClientSignupForm);

    expect(
      result.errorOrNull,
      const AccountValidationFailure({
        AccountField.email: AccountFieldIssue.duplicate,
      }),
    );
  });

  test('verifyEmail maps invalid_code', () async {
    final options = RequestOptions(path: '/api/auth/email/verify');
    when(
      () => remote.verifyEmail(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: 400,
          data: {'code': 'invalid_code', 'message': 'x', 'errors': []},
        ),
      ),
    );

    final result = await repository.verifyEmail(
      email: 'ana@vanep.com.br',
      code: '000000',
    );

    expect(result.errorOrNull, const InvalidCodeAccountFailure());
  });

  test('resendEmailVerification succeeds on 202', () async {
    when(() => remote.resendEmailVerification(any())).thenAnswer((_) async {});

    final result = await repository.resendEmailVerification('ana@vanep.com.br');

    expect(result.isOk, isTrue);
  });
}
