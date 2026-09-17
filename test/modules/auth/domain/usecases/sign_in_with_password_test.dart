import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_in_with_password.dart';

import '../../auth_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  test('SignInWithPassword trims the e-mail and delegates', () async {
    final session = FakeAuthSession();
    when(
      () => repository.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => Ok<AuthFailure, AuthSession>(session));

    final result = await SignInWithPassword(repository)(
      email: '  ana@vanep.com.br ',
      password: 'secret1',
    );

    expect(result.valueOrNull, session);
    verify(
      () => repository.signInWithPassword(
        email: 'ana@vanep.com.br',
        password: 'secret1',
      ),
    ).called(1);
  });
}
