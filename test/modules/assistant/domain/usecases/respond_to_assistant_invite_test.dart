import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';

import '../../mocks/assistant_mocks.dart';

void main() {
  late MockAssistantRepository repository;
  late RespondToAssistantInvite respond;

  setUp(() {
    repository = MockAssistantRepository();
    respond = RespondToAssistantInvite(repository);
  });

  test('accepting calls accept', () async {
    when(() => repository.acceptInvite('invite'))
        .thenAnswer((_) async => const Ok(null));

    final result = await respond('invite', InviteResponse.accept);

    expect(result.isOk, isTrue);
    verifyNever(() => repository.rejectInvite(any()));
  });

  test('rejecting calls reject and passes failures through', () async {
    when(() => repository.rejectInvite('invite'))
        .thenAnswer((_) async => const Err(AssistantFailure.expiredInvite));

    final result = await respond('invite', InviteResponse.reject);

    expect(result.errorOrNull, AssistantFailure.expiredInvite);
    verifyNever(() => repository.acceptInvite(any()));
  });
}
