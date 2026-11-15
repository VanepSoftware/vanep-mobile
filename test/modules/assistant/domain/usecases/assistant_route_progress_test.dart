import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_row_state.dart';

import '../../fixtures/assistant_route_fixtures.dart';

List<String> sequencesOf(Iterable<dynamic> stops) =>
    stops.map((stop) => 'stop-${stop.sequence}').toList();

void main() {
  group('current stop', () {
    test('is the first stop by sequence that is not finished', () {
      expect(testRouteOnPickup().currentStop?.token, 'stop-3');
    });

    test('does not exist before the trip starts', () {
      expect(testRouteNotStarted().currentStop, isNull);
    });

    test('defines the leg in progress', () {
      expect(testRouteOnPickup().currentLeg, TripLeg.outbound);
    });

    test('is numbered within its leg', () {
      final route = testRouteOnPickup();

      expect(route.currentStopNumber, 3);
      expect(route.stopCountOf(TripLeg.outbound), 6);
    });
  });

  group('upcoming stops', () {
    test('are the next three of the same leg', () {
      expect(sequencesOf(testRouteOnPickup().nextStops()), [
        'stop-4',
        'stop-5',
        'stop-6',
      ]);
    });

    test('never cross into the other leg', () {
      expect(sequencesOf(testRouteAtSchool().nextStops()), ['stop-6']);
    });

    test('before the trip starts, the first three outbound stops', () {
      expect(sequencesOf(testRouteNotStarted().firstStops()), [
        'stop-1',
        'stop-2',
        'stop-3',
      ]);
    });
  });

  group('legs', () {
    test('split the stops by kind', () {
      final route = testRouteOnPickup();

      expect(sequencesOf(route.stopsOf(TripLeg.inbound)), ['stop-7', 'stop-8']);
      expect(route.stopsOf(TripLeg.outbound), hasLength(6));
    });
  });

  group('boarding status', () {
    final route = testRouteOnPickup();

    BoardingStatus statusOf(String name) => route.boardingStatusOf(
      'passenger-${name.toLowerCase()}',
      TripLeg.outbound,
    );

    test('boarded when the pickup entry is done', () {
      expect(statusOf('Helena'), BoardingStatus.boarded);
    });

    test('no-show when the pickup entry was skipped', () {
      expect(statusOf('Laura'), BoardingStatus.noShow);
    });

    test('pending while the pickup entry is pending', () {
      expect(statusOf('Beatriz'), BoardingStatus.pending);
    });

    test('not going today when an entry is absent', () {
      expect(statusOf('Ana'), BoardingStatus.notGoingToday);
    });

    test('stays boarded while the drop-off entry is pending', () {
      expect(
        testRouteAtSchool().boardingStatusOf(
          'passenger-helena',
          TripLeg.outbound,
        ),
        BoardingStatus.boarded,
      );
    });

    test('dropped off once the drop-off entry is done', () {
      expect(
        testRouteAfterFirstSchool().boardingStatusOf(
          'passenger-helena',
          TripLeg.outbound,
        ),
        BoardingStatus.droppedOff,
      );
    });
  });

  group('headcount', () {
    test('counts each status once per passenger of the leg', () {
      final counts = testRouteOnPickup().boardingCountsOf(TripLeg.outbound);

      expect(counts[BoardingStatus.boarded], 3);
      expect(counts[BoardingStatus.pending], 3);
      expect(counts[BoardingStatus.noShow], 1);
      expect(counts[BoardingStatus.notGoingToday], 1);
    });

    test('the total leaves out who is not going today', () {
      expect(testRouteOnPickup().expectedPassengerCountOf(TripLeg.outbound), 7);
    });
  });

  group('stop rows', () {
    final route = testRouteOnPickup();

    test('a finished stop where everyone boarded is done', () {
      expect(route.stopRowStateOf(route.stops[0]), StopRowState.done);
    });

    test('a finished stop with a no-show is done with an issue', () {
      expect(route.stopRowStateOf(route.stops[1]), StopRowState.doneWithIssue);
    });

    test('the current stop is current', () {
      expect(route.stopRowStateOf(route.stops[2]), StopRowState.current);
    });

    test('later stops are upcoming', () {
      expect(route.stopRowStateOf(route.stops[3]), StopRowState.upcoming);
    });

    test('before the trip starts every stop is upcoming', () {
      final notStarted = testRouteNotStarted();
      expect(notStarted.stops.map(notStarted.stopRowStateOf).toSet(), {
        StopRowState.upcoming,
      });
    });
  });

  group('onboard groups', () {
    List<String> namesOf(List<dynamic> passengers) =>
        passengers.map((passenger) => passenger.name as String).toList();

    test('split the leg passengers by boarding status, in stop order', () {
      final groups = testRouteOnPickup().onboardGroupsOf(TripLeg.outbound);

      expect(namesOf(groups.onBoard), ['Davi', 'Helena', 'Theo']);
      expect(namesOf(groups.awaiting), ['Beatriz', 'Gabriel', 'Miguel']);
      expect(namesOf(groups.didNotBoard), ['Laura']);
      expect(namesOf(groups.notGoingToday), ['Ana']);
    });

    test('the stop where a no-show happened is kept for the correction', () {
      final route = testRouteOnPickup();

      expect(
        route.boardingStopOf('passenger-laura', TripLeg.outbound)?.token,
        'stop-2',
      );
    });
  });

  group('stop confirmation', () {
    test('lists only the pending passengers of the stop', () {
      final route = testRouteOnPickup();
      final names = route
          .passengersToConfirmAt(route.currentStop!)
          .map((passenger) => passenger.name);

      expect(names, ['Beatriz', 'Gabriel']);
    });

    test('at a drop-off, only passengers on board are listed', () {
      final route = testRouteOnPickup();
      final school = route.stops[4];
      final names = route
          .passengersToConfirmAt(school)
          .map((passenger) => passenger.name);

      expect(names, ['Helena', 'Davi', 'Theo']);
    });

    test('at a school, names who continues to a later school', () {
      final route = testRouteAtSchool();
      final names = route
          .passengersContinuingAfter(route.currentStop!)
          .map((passenger) => passenger.name);

      expect(names, ['Miguel']);
    });

    test('at a school, nobody continues when it is the last one', () {
      final route = testRouteAtSchool();
      final lastSchool = route.stopsOf(TripLeg.outbound).last;

      expect(route.passengersContinuingAfter(lastSchool), isEmpty);
    });
  });
}
