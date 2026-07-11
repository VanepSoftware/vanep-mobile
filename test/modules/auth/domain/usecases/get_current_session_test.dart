import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/get_current_session.dart';

import '../../auth_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  late MockAuthRepository repository;
  late GetCurrentSession usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = GetCurrentSession(repository);
  });

  test('returns the persisted session when present', () async {
    final session = FakeAuthSession();
    when(repository.currentSession).thenAnswer(
      (_) async => Ok<AuthFailure, AuthSession?>(session),
    );

    final result = await usecase();

    expect(result.valueOrNull, session);
  });

  test('returns null value when nobody is signed in', () async {
    when(repository.currentSession).thenAnswer(
      (_) async => const Ok<AuthFailure, AuthSession?>(null),
    );

    final result = await usecase();

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
  });
}
