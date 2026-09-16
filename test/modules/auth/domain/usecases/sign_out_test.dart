import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_out.dart';

import '../../auth_mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  test('SignOut delegates to the repository', () async {
    when(
      repository.signOut,
    ).thenAnswer((_) async => const Ok<AuthFailure, void>(null));

    final result = await SignOut(repository)();

    expect(result.isOk, isTrue);
    verify(repository.signOut).called(1);
  });
}
