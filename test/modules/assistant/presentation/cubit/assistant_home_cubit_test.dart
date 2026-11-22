import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

void main() {
  late MockFindAssistantHomeOverview findHomeOverview;
  late MockFindAssistantTodayRoute findTodayRoute;
  late MockConfirmStopPassengers confirmStopPassengers;
  late MockUndoStopConfirmation undoStopConfirmation;
  late MockMarkPresentInVan markPresentInVan;
  late MockRespondToAssistantInvite respondToInvite;

  final carlosToken = testAssistantVanPrimary.token;
  final ritaToken = testAssistantVanSecondary.token;

  AssistantHomeCubit buildCubit() => AssistantHomeCubit(
    findHomeOverview: findHomeOverview,
    findTodayRoute: findTodayRoute,
    confirmStopPassengers: confirmStopPassengers,
    undoStopConfirmation: undoStopConfirmation,
    markPresentInVan: markPresentInVan,
    respondToInvite: respondToInvite,
    clock: () => DateTime(2026, 10, 14, 6),
  );

  setUpAll(() => registerFallbackValue(testStopConfirmationAtPickup));

  setUp(() {
    findHomeOverview = MockFindAssistantHomeOverview();
    findTodayRoute = MockFindAssistantTodayRoute();
    confirmStopPassengers = MockConfirmStopPassengers();
    undoStopConfirmation = MockUndoStopConfirmation();
    markPresentInVan = MockMarkPresentInVan();
    respondToInvite = MockRespondToAssistantInvite();
    when(() => findHomeOverview())
        .thenAnswer((_) async => Ok(testHomeOverviewTwoVans));
    when(() => findTodayRoute(carlosToken))
        .thenAnswer((_) async => Ok(testRouteOnPickup()));
    when(() => findTodayRoute(ritaToken))
        .thenAnswer((_) async => const Ok(null));
  });

  group('load', () {
    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'loads the links and the route of the default van',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const AssistantHomeState(),
        AssistantHomeState(
          status: AssistantHomeLoadStatus.ready,
          overview: testHomeOverviewTwoVans,
          selectedVanToken: carlosToken,
          route: testRouteOnPickup(),
        ),
      ],
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'the home status is derived from what was loaded',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) =>
          expect(cubit.state.homeStatus, isA<AssistantHomeOnRouteBoarding>()),
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'keeps the failure when the links cannot be loaded',
      build: () {
        when(() => findHomeOverview())
            .thenAnswer((_) async => const Err(AssistantFailure.network));
        return buildCubit();
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const AssistantHomeState(),
        const AssistantHomeState(
          status: AssistantHomeLoadStatus.loadFailed,
          failure: AssistantFailure.network,
        ),
      ],
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'does not ask for a route when the selected van is paused',
      build: () {
        when(() => findHomeOverview())
            .thenAnswer((_) async => Ok(testHomeOverviewCarlosPaused));
        return buildCubit();
      },
      act: (cubit) => cubit.load(selectedVanToken: carlosToken),
      verify: (cubit) {
        verifyNever(() => findTodayRoute(any()));
        expect(cubit.state.homeStatus, isA<AssistantHomeAccessPaused>());
      },
    );
  });

  blocTest<AssistantHomeCubit, AssistantHomeState>(
    'a van chosen before the load finishes is the one loaded',
    build: buildCubit,
    act: (cubit) async {
      await cubit.selectVan(ritaToken);
      await cubit.load();
    },
    verify: (cubit) => expect(cubit.state.selectedVanToken, ritaToken),
  );

  blocTest<AssistantHomeCubit, AssistantHomeState>(
    'a van chosen while the default route is loading wins',
    build: () {
      final slowRoute = Completer<void>();
      when(() => findTodayRoute(carlosToken)).thenAnswer((_) async {
        await slowRoute.future;
        return Ok(testRouteOnPickup());
      });
      addTearDown(() {
        if (!slowRoute.isCompleted) slowRoute.complete();
      });
      final cubit = buildCubit();
      Future<void>.delayed(Duration.zero, () async {
        await cubit.selectVan(ritaToken);
        slowRoute.complete();
      });
      return cubit;
    },
    act: (cubit) => cubit.load(),
    wait: const Duration(milliseconds: 50),
    verify: (cubit) => expect(cubit.state.selectedVanToken, ritaToken),
  );

  blocTest<AssistantHomeCubit, AssistantHomeState>(
    'selecting another van loads that van route',
    build: buildCubit,
    seed: () => AssistantHomeState(
      status: AssistantHomeLoadStatus.ready,
      overview: testHomeOverviewTwoVans,
      selectedVanToken: carlosToken,
      route: testRouteOnPickup(),
    ),
    act: (cubit) => cubit.selectVan(ritaToken),
    expect: () => [
      AssistantHomeState(
        status: AssistantHomeLoadStatus.ready,
        overview: testHomeOverviewTwoVans,
        selectedVanToken: ritaToken,
      ),
    ],
  );

  group('confirming a stop', () {
    final readyOnPickup = AssistantHomeState(
      status: AssistantHomeLoadStatus.ready,
      overview: testHomeOverviewTwoVans,
      selectedVanToken: carlosToken,
      route: testRouteOnPickup(),
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'sends the batch of the current stop and keeps the server route',
      build: () {
        when(() => confirmStopPassengers(any()))
            .thenAnswer((_) async => Ok(testRouteAtSchool()));
        return buildCubit();
      },
      seed: () => readyOnPickup,
      act: (cubit) => cubit.confirmCurrentStop(
        selectedPassengerTokens: {'passenger-beatriz'},
      ),
      expect: () => [
        readyOnPickup.copyWith(isConfirming: true),
        readyOnPickup.copyWith(
          route: testRouteAtSchool(),
          lastConfirmation: StopConfirmation(
            vanToken: carlosToken,
            stopToken: 'stop-3',
            confirmedPassengerTokens: const ['passenger-beatriz'],
            skippedPassengers: const {
              'passenger-gabriel': NoShowReason.notAtStop,
            },
          ),
        ),
      ],
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'a failed batch changes no status and reports the failure',
      build: () {
        when(() => confirmStopPassengers(any()))
            .thenAnswer((_) async => const Err(AssistantFailure.network));
        return buildCubit();
      },
      seed: () => readyOnPickup,
      act: (cubit) => cubit.confirmCurrentStop(
        selectedPassengerTokens: {'passenger-beatriz', 'passenger-gabriel'},
      ),
      expect: () => [
        readyOnPickup.copyWith(isConfirming: true),
        readyOnPickup.copyWith(actionFailure: AssistantFailure.network),
      ],
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'undo restores the route the server returns',
      build: () {
        when(
          () =>
              undoStopConfirmation(vanToken: carlosToken, stopToken: 'stop-3'),
        ).thenAnswer((_) async => Ok(testRouteOnPickup()));
        return buildCubit();
      },
      seed: () => readyOnPickup.copyWith(
        route: testRouteAtSchool(),
        lastConfirmation: testStopConfirmationAtPickup,
      ),
      act: (cubit) => cubit.undoLastConfirmation(),
      expect: () => [readyOnPickup],
    );
  });

  group('answering the invite', () {
    final withInvite = AssistantHomeState(
      status: AssistantHomeLoadStatus.ready,
      overview: AssistantHomeOverview(pendingInvite: testAssistantInvite),
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'accepting reloads the home',
      build: () {
        when(
          () =>
              respondToInvite(testAssistantInvite.token, InviteResponse.accept),
        ).thenAnswer((_) async => const Ok(null));
        return buildCubit();
      },
      seed: () => withInvite,
      act: (cubit) => cubit.answerInvite(InviteResponse.accept),
      verify: (_) => verify(() => findHomeOverview()).called(1),
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'a failed answer keeps the invite and reports',
      build: () {
        when(
          () =>
              respondToInvite(testAssistantInvite.token, InviteResponse.reject),
        ).thenAnswer((_) async => const Err(AssistantFailure.expiredInvite));
        return buildCubit();
      },
      seed: () => withInvite,
      act: (cubit) => cubit.answerInvite(InviteResponse.reject),
      expect: () => [
        withInvite.copyWith(actionFailure: AssistantFailure.expiredInvite),
      ],
    );
  });

  group('correcting a no-show', () {
    final readyOnPickup = AssistantHomeState(
      status: AssistantHomeLoadStatus.ready,
      overview: testHomeOverviewTwoVans,
      selectedVanToken: carlosToken,
      route: testRouteOnPickup(),
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'confirms the boarding at the stop where it was skipped',
      build: () {
        when(() => confirmStopPassengers(any()))
            .thenAnswer((_) async => Ok(testRouteAtSchool()));
        return buildCubit();
      },
      seed: () => readyOnPickup,
      act: (cubit) => cubit.correctNoShow('passenger-laura'),
      expect: () => [
        readyOnPickup.copyWith(isConfirming: true),
        readyOnPickup.copyWith(route: testRouteAtSchool()),
      ],
      verify: (_) => verify(
        () => confirmStopPassengers(
          StopConfirmation(
            vanToken: carlosToken,
            stopToken: 'stop-2',
            confirmedPassengerTokens: const ['passenger-laura'],
          ),
        ),
      ).called(1),
    );

    blocTest<AssistantHomeCubit, AssistantHomeState>(
      'a failed correction keeps the student as not boarded',
      build: () {
        when(() => confirmStopPassengers(any()))
            .thenAnswer((_) async => const Err(AssistantFailure.network));
        return buildCubit();
      },
      seed: () => readyOnPickup,
      act: (cubit) => cubit.correctNoShow('passenger-laura'),
      expect: () => [
        readyOnPickup.copyWith(isConfirming: true),
        readyOnPickup.copyWith(actionFailure: AssistantFailure.network),
      ],
    );
  });

  blocTest<AssistantHomeCubit, AssistantHomeState>(
    'marks the assistant as present in the van',
    build: () {
      when(() => markPresentInVan(carlosToken))
          .thenAnswer((_) async => const Ok(null));
      return buildCubit();
    },
    seed: () => AssistantHomeState(
      status: AssistantHomeLoadStatus.ready,
      overview: testHomeOverviewTwoVans,
      selectedVanToken: carlosToken,
      route: testRouteNotStarted(),
    ),
    act: (cubit) => cubit.confirmPresenceInVan(),
    verify: (cubit) => expect(cubit.state.isPresentInVan, isTrue),
  );
}
