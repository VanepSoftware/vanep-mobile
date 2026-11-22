import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_trip_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';

void expectRoundTrip<T>(
  List<T> values,
  String Function(T) toApi,
  T? Function(Object?) fromApi,
) {
  for (final value in values) {
    expect(fromApi(toApi(value)), value, reason: '$value');
  }
}

void main() {
  test('every wire value round-trips', () {
    expectRoundTrip(
      RouteStopKind.values,
      RouteStopKind.toApi,
      RouteStopKind.fromApi,
    );
    expectRoundTrip(
      RouteStopStatus.values,
      RouteStopStatus.toApi,
      RouteStopStatus.fromApi,
    );
    expectRoundTrip(
      ChecklistStatus.values,
      ChecklistStatus.toApi,
      ChecklistStatus.fromApi,
    );
    expectRoundTrip(
      NoShowReason.values,
      NoShowReason.toApi,
      NoShowReason.fromApi,
    );
    expectRoundTrip(
      AssistantTripStatus.values,
      AssistantTripStatus.toApi,
      AssistantTripStatus.fromApi,
    );
    expectRoundTrip(
      AssistantLinkStatus.values,
      AssistantLinkStatus.toApi,
      AssistantLinkStatus.fromApi,
    );
    expectRoundTrip(AbsenceKind.values, AbsenceKind.toApi, AbsenceKind.fromApi);
    expectRoundTrip(
      AbsenceSource.values,
      AbsenceSource.toApi,
      AbsenceSource.fromApi,
    );
  });

  test('wire values match the data model enums', () {
    expect(RouteStopKind.values.map(RouteStopKind.toApi), [
      'PICKUP_HOME',
      'DROPOFF_SCHOOL',
      'PICKUP_SCHOOL',
      'DROPOFF_HOME',
    ]);
    expect(ChecklistStatus.values.map(ChecklistStatus.toApi), [
      'PENDING',
      'DONE',
      'SKIPPED',
      'ABSENT',
    ]);
    expect(NoShowReason.values.map(NoShowReason.toApi), [
      'NOT_AT_STOP',
      'RETURNED_HOME',
      'PICKED_UP_BY_GUARDIAN',
      'SICK',
      'OTHER',
    ]);
  });

  test('unknown wire values are not guessed', () {
    expect(RouteStopKind.fromApi('BUS_STOP'), isNull);
    expect(ChecklistStatus.fromApi(null), isNull);
  });

  test('stop kinds know their leg and whether they board', () {
    expect(RouteStopKind.pickupHome.leg, TripLeg.outbound);
    expect(RouteStopKind.dropOffSchool.leg, TripLeg.outbound);
    expect(RouteStopKind.pickupSchool.leg, TripLeg.inbound);
    expect(RouteStopKind.dropOffHome.leg, TripLeg.inbound);
    expect(RouteStopKind.pickupSchool.isBoarding, isTrue);
    expect(RouteStopKind.dropOffSchool.isBoarding, isFalse);
  });
}
