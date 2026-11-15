import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/confirm_stop_passengers.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_today_route.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/find_assistant_home_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/mark_present_in_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/undo_stop_confirmation.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

final vanToken = testAssistantVanPrimary.token;

void main() {
  late MockAssistantRouteRepository repository;

  setUpAll(() => registerFallbackValue(testStopConfirmationAtPickup));

  setUp(() => repository = MockAssistantRouteRepository());

  group('buildStopConfirmation', () {
    test('selected passengers are confirmed, the rest skipped', () {
      final route = testRouteOnPickup();

      final confirmation = buildStopConfirmation(
        vanToken: vanToken,
        route: route,
        stop: route.stops[2],
        selectedPassengerTokens: {'passenger-beatriz'},
      );

      expect(confirmation.confirmedPassengerTokens, ['passenger-beatriz']);
      expect(confirmation.skippedPassengers, {
        'passenger-gabriel': NoShowReason.notAtStop,
      });
    });

    test('a chosen reason replaces the default one', () {
      final route = testRouteOnPickup();

      final confirmation = buildStopConfirmation(
        vanToken: vanToken,
        route: route,
        stop: route.stops[2],
        selectedPassengerTokens: const {},
        reasons: {'passenger-gabriel': NoShowReason.sick},
      );

      expect(
        confirmation.skippedPassengers['passenger-gabriel'],
        NoShowReason.sick,
      );
    });

    test('notes are kept, trimmed, only for skipped passengers', () {
      final route = testRouteOnPickup();

      final confirmation = buildStopConfirmation(
        vanToken: vanToken,
        route: route,
        stop: route.stops[2],
        selectedPassengerTokens: {'passenger-beatriz'},
        reasons: {'passenger-gabriel': NoShowReason.other},
        notes: {
          'passenger-gabriel': '  foi ao médico ',
          'passenger-beatriz': 'ignorado',
        },
      );

      expect(confirmation.skipNotes, {'passenger-gabriel': 'foi ao médico'});
    });

    test('at a school the default reason is other', () {
      final route = testRouteAtSchool();

      final confirmation = buildStopConfirmation(
        vanToken: vanToken,
        route: route,
        stop: route.stops[2],
        selectedPassengerTokens: {'passenger-helena'},
      );

      expect(confirmation.skippedPassengers, {
        'passenger-davi': NoShowReason.other,
      });
    });

    test('passengers already handled are not sent again', () {
      final route = testRouteOnPickup();

      final confirmation = buildStopConfirmation(
        vanToken: vanToken,
        route: route,
        stop: route.stops[3],
        selectedPassengerTokens: {'passenger-miguel', 'passenger-ana'},
      );

      expect(confirmation.confirmedPassengerTokens, ['passenger-miguel']);
      expect(confirmation.skippedPassengers, isEmpty);
    });
  });

  group('use cases delegate to the repository', () {
    test('FindAssistantHomeOverview', () async {
      when(() => repository.findHomeOverview())
          .thenAnswer((_) async => Ok(testHomeOverviewTwoVans));

      final result = await FindAssistantHomeOverview(repository)();

      expect(result.valueOrNull, testHomeOverviewTwoVans);
    });

    test('FindAssistantTodayRoute', () async {
      final route = testRouteOnPickup();
      when(() => repository.findTodayRoute(vanToken))
          .thenAnswer((_) async => Ok(route));

      final result = await FindAssistantTodayRoute(repository)(vanToken);

      expect(result.valueOrNull, route);
    });

    test('ConfirmStopPassengers returns the route the server owns', () async {
      final route = testRouteAtSchool();
      when(() => repository.confirmStop(any()))
          .thenAnswer((_) async => Ok(route));

      final result = await ConfirmStopPassengers(repository)(
        testStopConfirmationAtPickup,
      );

      expect(result.valueOrNull, route);
      verify(() => repository.confirmStop(testStopConfirmationAtPickup))
          .called(1);
    });

    test('UndoStopConfirmation', () async {
      final route = testRouteOnPickup();
      when(
        () => repository.undoStopConfirmation(
          vanToken: vanToken,
          stopToken: 'stop-3',
        ),
      ).thenAnswer((_) async => Ok(route));

      final result = await UndoStopConfirmation(repository)(
        vanToken: vanToken,
        stopToken: 'stop-3',
      );

      expect(result.valueOrNull, route);
    });

    test('MarkPresentInVan passes failures through', () async {
      when(() => repository.markPresentInVan(vanToken))
          .thenAnswer((_) async => const Err(AssistantFailure.network));

      final result = await MarkPresentInVan(repository)(vanToken);

      expect(result.errorOrNull, AssistantFailure.network);
    });
  });

  test('a stop confirmation is a value', () {
    expect(
      testStopConfirmationAtPickup,
      StopConfirmation(
        vanToken: testAssistantVanPrimary.token,
        stopToken: 'stop-3',
        confirmedPassengerTokens: ['passenger-beatriz'],
        skippedPassengers: {'passenger-gabriel': NoShowReason.notAtStop},
      ),
    );
  });
}
