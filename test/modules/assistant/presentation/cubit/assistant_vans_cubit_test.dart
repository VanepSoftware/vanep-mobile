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

  setUp(() {
    findAssistantVans = MockFindAssistantVans();
  });

  blocTest<AssistantVansCubit, AssistantVansState>(
    'loads the overview',
    build: () {
      when(() => findAssistantVans())
          .thenAnswer((_) async => Ok(testAssistantVansOverview));
      return AssistantVansCubit(
        findAssistantVans: findAssistantVans,
        respondToInvite: MockRespondToAssistantInvite(),
      );
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
      return AssistantVansCubit(
        findAssistantVans: findAssistantVans,
        respondToInvite: MockRespondToAssistantInvite(),
      );
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
      return AssistantVansCubit(
        findAssistantVans: findAssistantVans,
        respondToInvite: MockRespondToAssistantInvite(),
      );
    },
    act: (cubit) async {
      await cubit.loadVans();
      await cubit.loadVans();
    },
    verify: (cubit) {
      expect(cubit.state.status, AssistantVansStatus.ready);
    },
  );

  group('answering the pending invite', () {
    late MockRespondToAssistantInvite respondToInvite;
    final ready = AssistantVansState(
      status: AssistantVansStatus.ready,
      overview: testAssistantVansOverview,
    );

    setUp(() => respondToInvite = MockRespondToAssistantInvite());

    blocTest<AssistantVansCubit, AssistantVansState>(
      'accepting reloads the vans',
      build: () {
        when(
          () => respondToInvite(
            testAssistantVansOverview.pendingInvite!.token,
            InviteResponse.accept,
          ),
        ).thenAnswer((_) async => const Ok(null));
        when(() => findAssistantVans())
            .thenAnswer((_) async => Ok(testAssistantVansOverview));
        return AssistantVansCubit(
          findAssistantVans: findAssistantVans,
          respondToInvite: respondToInvite,
        );
      },
      seed: () => ready,
      act: (cubit) => cubit.answerInvite(InviteResponse.accept),
      verify: (_) => verify(() => findAssistantVans()).called(1),
    );

    blocTest<AssistantVansCubit, AssistantVansState>(
      'a failed answer keeps the list and reports the failure',
      build: () {
        when(
          () => respondToInvite(
            testAssistantVansOverview.pendingInvite!.token,
            InviteResponse.reject,
          ),
        ).thenAnswer((_) async => const Err(AssistantFailure.network));
        return AssistantVansCubit(
          findAssistantVans: findAssistantVans,
          respondToInvite: respondToInvite,
        );
      },
      seed: () => ready,
      act: (cubit) => cubit.answerInvite(InviteResponse.reject),
      expect: () => [
        AssistantVansState(
          status: AssistantVansStatus.ready,
          overview: testAssistantVansOverview,
          failure: AssistantFailure.network,
        ),
      ],
    );
  });
}
