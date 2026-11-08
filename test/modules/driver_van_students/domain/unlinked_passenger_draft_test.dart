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

  test('checking a day applies the default time of that leg', () {
    final draft = const UnlinkedPassengerDraft()
        .toggleLeg(Weekday.monday, RouteLeg.outbound)
        .toggleLeg(Weekday.monday, RouteLeg.homebound);

    expect(draft.isLegSelected(Weekday.monday, RouteLeg.outbound), isTrue);
    expect(
      draft.timeOf(Weekday.monday, RouteLeg.outbound),
      defaultOutboundPickupTime,
    );
    expect(
      draft.timeOf(Weekday.monday, RouteLeg.homebound),
      defaultHomeboundPickupTime,
    );
    expect(
      draft.errors,
      isNot(contains(UnlinkedPassengerDraftError.timeRequired)),
    );
  });

  test('a newly checked day uses the default, not another day time', () {
    final draft = completeDraft().toggleLeg(Weekday.tuesday, RouteLeg.outbound);

    expect(draft.timeOf(Weekday.monday, RouteLeg.outbound), morningPickup);
    expect(
      draft.timeOf(Weekday.tuesday, RouteLeg.outbound),
      defaultOutboundPickupTime,
    );
  });

  test('changing the default keeps a time the driver already set', () {
    const custom = ClockTime(hour: 7, minute: 15);
    const nextDefault = ClockTime(hour: 7, minute: 45);
    final draft = const UnlinkedPassengerDraft()
        .toggleLeg(Weekday.monday, RouteLeg.outbound)
        .changeTime(Weekday.monday, RouteLeg.outbound, custom)
        .changeDefaultTime(RouteLeg.outbound, nextDefault);

    expect(draft.defaultTimeOf(RouteLeg.outbound), nextDefault);
    expect(draft.timeOf(Weekday.monday, RouteLeg.outbound), custom);
    expect(draft.defaultTimeOf(RouteLeg.homebound), defaultHomeboundPickupTime);
  });

  test('a day checked after the default changes uses the new default', () {
    const nextDefault = ClockTime(hour: 7, minute: 45);
    final draft = const UnlinkedPassengerDraft()
        .toggleLeg(Weekday.monday, RouteLeg.outbound)
        .changeDefaultTime(RouteLeg.outbound, nextDefault)
        .toggleLeg(Weekday.wednesday, RouteLeg.outbound);

    expect(
      draft.timeOf(Weekday.monday, RouteLeg.outbound),
      defaultOutboundPickupTime,
    );
    expect(draft.timeOf(Weekday.wednesday, RouteLeg.outbound), nextDefault);
  });

  test('toggling a selected leg removes it', () {
    final draft = completeDraft().toggleLeg(Weekday.monday, RouteLeg.homebound);

    expect(draft.isLegSelected(Weekday.monday, RouteLeg.homebound), isFalse);
    expect(draft.timeOf(Weekday.monday, RouteLeg.homebound), isNull);
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
