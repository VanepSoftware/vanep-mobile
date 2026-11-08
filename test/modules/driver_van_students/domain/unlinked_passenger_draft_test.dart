import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

import '../driver_van_students_fixtures.dart';

void main() {
  test('a complete draft has no errors', () {
    expect(completeDraft().errors, isEmpty);
  });

  test('an empty draft lists every required field', () {
    expect(const UnlinkedPassengerDraft().errors, {
      UnlinkedPassengerDraftError.nameRequired,
      UnlinkedPassengerDraftError.schoolRequired,
      UnlinkedPassengerDraftError.schoolShiftRequired,
      UnlinkedPassengerDraftError.cityRequired,
      UnlinkedPassengerDraftError.streetRequired,
      UnlinkedPassengerDraftError.zipCodeInvalid,
      UnlinkedPassengerDraftError.legRequired,
    });
  });

  test('a leg without time and long texts are refused', () {
    final complete = completeDraft();
    final draft = complete.copyWith(
      name: 'a' * 256,
      notes: 'b' * 501,
      legTimes: {
        ...complete.legTimes,
        (Weekday.tuesday, RouteLeg.homebound): null,
      },
    );

    expect(draft.errors, {
      UnlinkedPassengerDraftError.nameTooLong,
      UnlinkedPassengerDraftError.timeRequired,
      UnlinkedPassengerDraftError.notesTooLong,
    });
  });

  test('the first leg of its kind starts without a time', () {
    final draft = const UnlinkedPassengerDraft().toggleLeg(
      Weekday.monday,
      RouteLeg.outbound,
    );

    expect(draft.isLegSelected(Weekday.monday, RouteLeg.outbound), isTrue);
    expect(draft.timeOf(Weekday.monday, RouteLeg.outbound), isNull);
    expect(draft.errors, contains(UnlinkedPassengerDraftError.timeRequired));
  });

  test('a new leg starts with the time already used by that leg', () {
    final draft = completeDraft().toggleLeg(Weekday.tuesday, RouteLeg.outbound);

    expect(draft.timeOf(Weekday.tuesday, RouteLeg.outbound), morningPickup);
  });

  test('toggling a selected leg removes it', () {
    final draft = completeDraft().toggleLeg(Weekday.monday, RouteLeg.homebound);

    expect(draft.isLegSelected(Weekday.monday, RouteLeg.homebound), isFalse);
  });

  test('applying a time changes only that leg on every day', () {
    const later = ClockTime(hour: 7, minute: 0);
    final draft = completeDraft()
        .toggleLeg(Weekday.tuesday, RouteLeg.outbound)
        .applyTimeToEveryDay(RouteLeg.outbound, later);

    expect(draft.timeOf(Weekday.monday, RouteLeg.outbound), later);
    expect(draft.timeOf(Weekday.tuesday, RouteLeg.outbound), later);
    expect(draft.timeOf(Weekday.monday, RouteLeg.homebound), noonPickup);
  });

  test('a full-time student rides the morning out and the afternoon back', () {
    final slots = completeDraft()
        .copyWith(schoolShift: SchoolShift.fullTime)
        .slots;

    expect(slots.map((slot) => (slot.leg, slot.shift)), [
      (RouteLeg.outbound, OperationShift.morning),
      (RouteLeg.homebound, OperationShift.afternoon),
    ]);
  });

  test('changing the time of a leg that is not selected does nothing', () {
    final draft = completeDraft();

    expect(
      draft.changeTime(Weekday.friday, RouteLeg.outbound, morningPickup),
      draft,
    );
  });
}
