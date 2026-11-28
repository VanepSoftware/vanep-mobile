import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockFindAssistantVans findAssistantVans;
  late MockRespondToAssistantInvite respondToInvite;

  setUp(() {
    findAssistantVans = MockFindAssistantVans();
    respondToInvite = MockRespondToAssistantInvite();
  });

  AssistantVansCubit buildCubit() => AssistantVansCubit(
    findAssistantVans: findAssistantVans,
    respondToAssistantInvite: respondToInvite,
  );

  final readyState = AssistantVansState(
    status: AssistantVansStatus.ready,
    overview: testAssistantVansOverview,
  );
  final inviteToken = testAssistantVansOverview.pendingInvite!.token;

  blocTest<AssistantVansCubit, AssistantVansState>(
    'loads the overview',
    build: () {
      when(() => findAssistantVans())
          .thenAnswer((_) async => Ok(testAssistantVansOverview));
      return buildCubit();
    },
    act: (cubit) => cubit.loadVans(),
    expect: () => [
      const AssistantVansState(),
      AssistantVansState(
        status: AssistantVansStatus.ready,
        overview: testAssistantVansOverview,
      ),
    ],
  );

  blocTest<AssistantVansCubit, AssistantVansState>(
    'fails and keeps the failure',
    build: () {
      when(() => findAssistantVans())
          .thenAnswer((_) async => const Err(AssistantFailure.network));
      return buildCubit();
    },
    act: (cubit) => cubit.loadVans(),
    expect: () => [
      const AssistantVansState(),
      const AssistantVansState(
        status: AssistantVansStatus.loadFailed,
        failure: AssistantFailure.network,
      ),
    ],
  );

  blocTest<AssistantVansCubit, AssistantVansState>(
    'loads again after a failure',
    build: () {
      var calls = 0;
      when(() => findAssistantVans()).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? const Err(AssistantFailure.network)
            : Ok(testAssistantVansOverview);
      });
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.loadVans();
      await cubit.loadVans();
    },
    verify: (cubit) {
      expect(cubit.state.status, AssistantVansStatus.ready);
    },
  );

  blocTest<AssistantVansCubit, AssistantVansState>(
    'accepts the invite, reloads the overview and tells the user',
    build: () {
      when(() => respondToInvite(inviteToken, InviteResponse.accept))
          .thenAnswer((_) async => const Ok(null));
      when(() => findAssistantVans())
          .thenAnswer((_) async => Ok(testAssistantVansOverview));
      return buildCubit();
    },
    seed: () => readyState,
    act: (cubit) => cubit.respondToInvite(InviteResponse.accept),
    expect: () => [
      readyState.copyWith(respondingInvite: InviteResponse.accept),
      readyState.copyWith(
        notice: const InviteRespondedNotice(InviteResponse.accept),
      ),
    ],
    verify: (_) => verify(() => findAssistantVans()).called(1),
  );

  blocTest<AssistantVansCubit, AssistantVansState>(
    'keeps the invite and reports the failure when rejecting fails',
    build: () {
      when(() => respondToInvite(inviteToken, InviteResponse.reject))
          .thenAnswer((_) async => const Err(AssistantFailure.network));
      return buildCubit();
    },
    seed: () => readyState,
    act: (cubit) => cubit.respondToInvite(InviteResponse.reject),
    expect: () => [
      readyState.copyWith(respondingInvite: InviteResponse.reject),
      readyState.copyWith(
        notice: const InviteResponseFailedNotice(AssistantFailure.network),
      ),
    ],
    verify: (_) => verifyNever(() => findAssistantVans()),
  );

  blocTest<AssistantVansCubit, AssistantVansState>(
    'ignores a second answer while one is in flight',
    build: buildCubit,
    seed: () => readyState.copyWith(respondingInvite: InviteResponse.accept),
    act: (cubit) => cubit.respondToInvite(InviteResponse.reject),
    expect: () => const <AssistantVansState>[],
    verify: (_) => verifyZeroInteractions(respondToInvite),
  );
}
