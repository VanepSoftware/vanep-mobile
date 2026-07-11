import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/exchange_authorization_code.dart';

import '../../auth_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late ExchangeAuthorizationCode usecase;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    repository = MockAuthRepository();
    usecase = ExchangeAuthorizationCode(repository);
  });

  test('delegates code and request to the repository and returns its session',
      () async {
    final session = FakeAuthSession();
    when(() => repository.exchangeCode(
          code: any(named: 'code'),
          request: any(named: 'request'),
        )).thenAnswer((_) async => Ok<AuthFailure, AuthSession>(session));

    final result = await usecase(
      code: 'auth-code',
      request: fakeAuthorizationRequest,
    );

    expect(result.valueOrNull, session);
    verify(() => repository.exchangeCode(
          code: 'auth-code',
          request: fakeAuthorizationRequest,
        )).called(1);
  });

  test('propagates repository failure', () async {
    when(() => repository.exchangeCode(
          code: any(named: 'code'),
          request: any(named: 'request'),
        )).thenAnswer(
      (_) async => const Err<AuthFailure, AuthSession>(NetworkAuthFailure()),
    );

    final result = await usecase(code: 'x', request: fakeAuthorizationRequest);

    expect(result.errorOrNull, const NetworkAuthFailure());
  });
}
