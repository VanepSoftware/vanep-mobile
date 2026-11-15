import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_trip_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/onboard_groups.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_row_state.dart';

const assistantUpcomingStopCount = 3;

extension AssistantRouteProgress on AssistantRouteSnapshot {
  bool get isOnRoute => tripStatus == AssistantTripStatus.inProgress;

  List<AssistantRouteStop> get orderedStops =>
      [...stops]..sort((first, second) => first.sequence - second.sequence);

  List<AssistantRouteStop> stopsOf(TripLeg leg) =>
      orderedStops.where((stop) => stop.kind.leg == leg).toList();

  int stopCountOf(TripLeg leg) => stopsOf(leg).length;

  AssistantRouteStop? get currentStop {
    if (!isOnRoute) return null;
    return orderedStops.where((stop) => !stop.status.isFinished).firstOrNull;
  }

  TripLeg? get currentLeg => currentStop?.kind.leg;

  int? get currentStopNumber {
    final stop = currentStop;
    if (stop == null) return null;
    return stopNumberOf(stop);
  }

  int stopNumberOf(AssistantRouteStop stop) =>
      stopsOf(stop.kind.leg).indexOf(stop) + 1;

  List<AssistantRouteStop> nextStops({int count = assistantUpcomingStopCount}) {
    final stop = currentStop;
    if (stop == null) return const [];
    return stopsOf(stop.kind.leg)
        .where((candidate) => candidate.sequence > stop.sequence)
        .take(count)
        .toList();
  }

  List<AssistantRouteStop> firstStops({
    int count = assistantUpcomingStopCount,
  }) => stopsOf(TripLeg.outbound).take(count).toList();

  List<String> passengerTokensOf(TripLeg leg) => {
    for (final stop in stopsOf(leg))
      for (final passenger in stop.passengers) passenger.token,
  }.toList();

  BoardingStatus boardingStatusOf(String passengerToken, TripLeg leg) {
    final entries = [
      for (final stop in stopsOf(leg))
        for (final passenger in stop.passengers)
          if (passenger.token == passengerToken) (stop.kind, passenger),
    ];
    final isAbsent =
        entries.any(
          (entry) => entry.$2.checklistStatus == ChecklistStatus.absent,
        ) ||
        isNotGoingToday(passengerToken);
    if (isAbsent) return BoardingStatus.notGoingToday;

    ChecklistStatus? statusAt({required bool boarding}) => entries
        .where((entry) => entry.$1.isBoarding == boarding)
        .firstOrNull
        ?.$2
        .checklistStatus;

    final boarding = statusAt(boarding: true);
    if (boarding == ChecklistStatus.skipped) return BoardingStatus.noShow;
    if (statusAt(boarding: false) == ChecklistStatus.done) {
      return BoardingStatus.droppedOff;
    }
    if (boarding == ChecklistStatus.done) return BoardingStatus.boarded;
    return BoardingStatus.pending;
  }

  bool isNotGoingToday(String passengerToken) => todayAbsences.any(
    (absence) =>
        absence.passengerToken == passengerToken &&
        absence.kind == AbsenceKind.notGoing,
  );

  Map<BoardingStatus, int> boardingCountsOf(TripLeg leg) {
    final counts = {for (final status in BoardingStatus.values) status: 0};
    for (final token in passengerTokensOf(leg)) {
      final status = boardingStatusOf(token, leg);
      counts[status] = counts[status]! + 1;
    }
    return counts;
  }

  int expectedPassengerCountOf(TripLeg leg) =>
      passengerTokensOf(leg).length -
      boardingCountsOf(leg)[BoardingStatus.notGoingToday]!;

  List<AssistantRoutePassenger> passengersToConfirmAt(
    AssistantRouteStop stop,
  ) => stop.passengers
      .where(
        (passenger) =>
            passenger.checklistStatus == ChecklistStatus.pending &&
            (stop.kind.isBoarding ||
                boardingStatusOf(passenger.token, stop.kind.leg) ==
                    BoardingStatus.boarded),
      )
      .toList();

  StopRowState stopRowStateOf(AssistantRouteStop stop) {
    if (stop == currentStop) return StopRowState.current;
    if (stop.status != RouteStopStatus.done) return StopRowState.upcoming;
    final hasIssue = stop.passengers.any(
      (passenger) => passenger.checklistStatus == ChecklistStatus.skipped,
    );
    return hasIssue ? StopRowState.doneWithIssue : StopRowState.done;
  }

  AssistantRouteStop? boardingStopOf(String passengerToken, TripLeg leg) {
    return stopsOf(leg)
        .where(
          (stop) =>
              stop.kind.isBoarding &&
              stop.passengers.any(
                (passenger) => passenger.token == passengerToken,
              ),
        )
        .firstOrNull;
  }

  OnboardGroups onboardGroupsOf(TripLeg leg) {
    final groups = {
      for (final status in BoardingStatus.values)
        status: <AssistantRoutePassenger>[],
    };
    final seen = <String>{};
    for (final stop in stopsOf(leg).where((stop) => stop.kind.isBoarding)) {
      final passengers = [...stop.passengers]
        ..sort((first, second) => first.name.compareTo(second.name));
      for (final passenger in passengers) {
        if (!seen.add(passenger.token)) continue;
        groups[boardingStatusOf(passenger.token, leg)]!.add(passenger);
      }
    }
    return OnboardGroups(
      onBoard: groups[BoardingStatus.boarded]!,
      awaiting: groups[BoardingStatus.pending]!,
      didNotBoard: groups[BoardingStatus.noShow]!,
      notGoingToday: groups[BoardingStatus.notGoingToday]!,
    );
  }

  List<AssistantRoutePassenger> passengersContinuingAfter(
    AssistantRouteStop stop,
  ) {
    return [
      for (final laterStop in stopsOf(stop.kind.leg))
        if (laterStop.sequence > stop.sequence && !laterStop.kind.isBoarding)
          for (final passenger in laterStop.passengers)
            if (boardingStatusOf(passenger.token, stop.kind.leg) ==
                BoardingStatus.boarded)
              passenger,
    ];
  }
}
