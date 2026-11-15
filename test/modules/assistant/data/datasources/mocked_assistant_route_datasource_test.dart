import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_home_scenario.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/derive_assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

DateTime fixedClock() => DateTime(2026, 10, 14, 6, 50);

Future<AssistantHomeStatus> homeStatusOf(
  AssistantHomeScenario scenario, {
  String? selectedVanToken,
}) async {
  final dataSource = MockedAssistantRouteDataSource(
    scenario: scenario,
    clock: fixedClock,
  );
  final overview = await dataSource.findHomeOverview();
  final selected = selectAssistantVanLink(overview.links, selectedVanToken);
  final route = selected == null
      ? null
      : await dataSource.findTodayRoute(selected.van.token);
  return deriveAssistantHomeStatus(
    links: overview.links,
    pendingInvite: overview.pendingInvite,
    selectedVanToken: selectedVanToken,
    route: route,
  );
}

void main() {
  group('each scenario renders its frame', () {
    test('noVan → aux-home-1', () async {
      expect(
        await homeStatusOf(AssistantHomeScenario.noVan),
        isA<AssistantHomeNoVan>(),
      );
    });

    test('inviteReceived → aux-home-2', () async {
      expect(
        await homeStatusOf(AssistantHomeScenario.inviteReceived),
        isA<AssistantHomeInviteReceived>(),
      );
    });

    test('beforeRoute → aux-home-3', () async {
      expect(
        await homeStatusOf(AssistantHomeScenario.beforeRoute),
        isA<AssistantHomeBeforeRoute>(),
      );
    });

    test('onRouteBoarding → aux-home-4, stop 5 of 10', () async {
      final status = await homeStatusOf(AssistantHomeScenario.onRouteBoarding);

      expect(status, isA<AssistantHomeOnRouteBoarding>());
      final route = (status as AssistantHomeOnRouteBoarding).route;
      expect(route.currentStopNumber, 5);
      expect(route.stopCountOf(TripLeg.outbound), 10);
    });

    test('accessPaused → aux-home-5 when the paused van is selected', () async {
      final status = await homeStatusOf(
        AssistantHomeScenario.accessPaused,
        selectedVanToken: mockedVanCarlosToken,
      );

      expect(status, isA<AssistantHomeAccessPaused>());
      expect(
        (status as AssistantHomeAccessPaused).otherActiveLinks,
        hasLength(1),
      );
    });

    test('accessPaused opens on the active van by default', () async {
      expect(
        await homeStatusOf(AssistantHomeScenario.accessPaused),
        isA<AssistantHomeBeforeRoute>(),
      );
    });

    test('onRouteDropOff → aux-home-6, stop 9 of 10', () async {
      final status = await homeStatusOf(AssistantHomeScenario.onRouteDropOff);

      expect(status, isA<AssistantHomeOnRouteDropOff>());
      expect(
        (status as AssistantHomeOnRouteDropOff).route.currentStopNumber,
        9,
      );
    });
  });

  test('the boarding frame has 7 on board and 6 awaiting out of 14', () async {
    final dataSource = MockedAssistantRouteDataSource(
      scenario: AssistantHomeScenario.onRouteBoarding,
      clock: fixedClock,
    );
    final route = (await dataSource.findTodayRoute(mockedVanCarlosToken))!;
    final counts = route.boardingCountsOf(TripLeg.outbound);

    expect(counts[BoardingStatus.boarded], 7);
    expect(counts[BoardingStatus.pending], 6);
    expect(counts[BoardingStatus.noShow], 1);
    expect(route.expectedPassengerCountOf(TripLeg.outbound), 14);
  });

  test('confirming a stop finishes it and moves to the next one', () async {
    final dataSource = MockedAssistantRouteDataSource(
      scenario: AssistantHomeScenario.onRouteBoarding,
      clock: fixedClock,
    );
    final before = (await dataSource.findTodayRoute(mockedVanCarlosToken))!;
    final stop = before.currentStop!;

    final after = await dataSource.confirmStop(
      StopConfirmation(
        vanToken: mockedVanCarlosToken,
        stopToken: stop.token,
        confirmedPassengerTokens: [stop.passengers.first.token],
        skippedPassengers: {stop.passengers.last.token: NoShowReason.sick},
      ),
    );

    final finished = after.stops.firstWhere((s) => s.token == stop.token);
    expect(finished.status, RouteStopStatus.done);
    expect(
      after.boardingStatusOf(stop.passengers.first.token, TripLeg.outbound),
      BoardingStatus.boarded,
    );
    expect(
      after.boardingStatusOf(stop.passengers.last.token, TripLeg.outbound),
      BoardingStatus.noShow,
    );
    expect(after.currentStopNumber, 6);
  });

  test('undo restores the stop as it was', () async {
    final dataSource = MockedAssistantRouteDataSource(
      scenario: AssistantHomeScenario.onRouteBoarding,
      clock: fixedClock,
    );
    final before = (await dataSource.findTodayRoute(mockedVanCarlosToken))!;
    final stop = before.currentStop!;
    await dataSource.confirmStop(
      StopConfirmation(
        vanToken: mockedVanCarlosToken,
        stopToken: stop.token,
        confirmedPassengerTokens: [
          for (final passenger in stop.passengers) passenger.token,
        ],
      ),
    );

    final restored = await dataSource.undoStopConfirmation(
      vanToken: mockedVanCarlosToken,
      stopToken: stop.token,
    );

    expect(restored, before);
  });

  test('scenario names come from the environment', () {
    expect(
      AssistantHomeScenario.fromName(' accessPaused '),
      AssistantHomeScenario.accessPaused,
    );
    expect(AssistantHomeScenario.fromName('unknown'), isNull);
  });
}
