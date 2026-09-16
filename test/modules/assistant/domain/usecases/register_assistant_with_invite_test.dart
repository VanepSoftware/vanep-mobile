import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/register_assistant_with_invite.dart';

import '../../mocks/assistant_mocks.dart';

void main() {
  late MockAssistantRepository repository;
  late RegisterAssistantWithInvite usecase;

  setUp(() {
    repository = MockAssistantRepository();
    usecase = RegisterAssistantWithInvite(repository);
  });

  test('delegates lean registration parameters to the repository', () async {
    when(
      () => repository.registerWithInvite(
        inviteToken: any(named: 'inviteToken'),
        name: any(named: 'name'),
        birthDate: any(named: 'birthDate'),
        email: any(named: 'email'),
        cpf: any(named: 'cpf'),
      ),
    ).thenAnswer((_) async => const Ok<AssistantFailure, void>(null));

    final result = await usecase(
      inviteToken: 'tok-invite',
      name: 'Carlos Santos',
      birthDate: '1995-04-12',
      email: 'carlos@example.com',
      cpf: '123.456.789-00',
    );

    expect(result, const Ok<AssistantFailure, void>(null));
    verify(
      () => repository.registerWithInvite(
        inviteToken: 'tok-invite',
        name: 'Carlos Santos',
        birthDate: '1995-04-12',
        email: 'carlos@example.com',
        cpf: '123.456.789-00',
      ),
    ).called(1);
  });

  test('forwards failure when personal data or invite is invalid', () async {
    when(
      () => repository.registerWithInvite(
        inviteToken: any(named: 'inviteToken'),
        name: any(named: 'name'),
        birthDate: any(named: 'birthDate'),
        email: any(named: 'email'),
        cpf: any(named: 'cpf'),
      ),
    ).thenAnswer(
      (_) async => const Err<AssistantFailure, void>(
        AssistantFailure.invalidPersonalData,
      ),
    );

    final result = await usecase(
      inviteToken: 'tok-invite',
      name: 'Carlos Santos',
      birthDate: 'invalid-date',
      email: 'carlos@example.com',
      cpf: 'invalid-cpf',
    );

    expect(
      result,
      const Err<AssistantFailure, void>(AssistantFailure.invalidPersonalData),
    );
  });
}
