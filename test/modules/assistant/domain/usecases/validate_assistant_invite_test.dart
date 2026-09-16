import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/validate_assistant_invite.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockAssistantRepository repository;
  late ValidateAssistantInvite usecase;

  setUp(() {
    repository = MockAssistantRepository();
    usecase = ValidateAssistantInvite(repository);
  });

  test('forwards the code to repository and returns ok with invite', () async {
    when(() => repository.validateInvite('VALID-CODE')).thenAnswer(
      (_) async => Ok<AssistantFailure, AssistantInvite>(testAssistantInvite),
    );

    final result = await usecase('VALID-CODE');

    expect(result, Ok<AssistantFailure, AssistantInvite>(testAssistantInvite));
    verify(() => repository.validateInvite('VALID-CODE')).called(1);
  });

  test('forwards failure when code is invalid or expired', () async {
    when(() => repository.validateInvite('EXPIRED-CODE')).thenAnswer(
      (_) async => const Err<AssistantFailure, AssistantInvite>(
        AssistantFailure.expiredInvite,
      ),
    );

    final result = await usecase('EXPIRED-CODE');

    expect(
      result,
      const Err<AssistantFailure, AssistantInvite>(
        AssistantFailure.expiredInvite,
      ),
    );
    verify(() => repository.validateInvite('EXPIRED-CODE')).called(1);
  });
}
