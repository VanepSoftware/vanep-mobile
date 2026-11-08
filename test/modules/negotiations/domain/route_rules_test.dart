import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/installment_preview.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/legs_summary.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

import '../negotiations_fixtures.dart';

void main() {
  group('deriveOperationShift', () {
    test('a single period keeps its shift on both legs', () {
      for (final leg in RouteLeg.values) {
        expect(
          deriveOperationShift(SchoolShift.morning, leg),
          OperationShift.morning,
        );
        expect(
          deriveOperationShift(SchoolShift.afternoon, leg),
          OperationShift.afternoon,
        );
        expect(
          deriveOperationShift(SchoolShift.night, leg),
          OperationShift.night,
        );
      }
    });

    test('full time goes in the morning and comes back in the afternoon', () {
      expect(
        deriveOperationShift(SchoolShift.fullTime, RouteLeg.outbound),
        OperationShift.morning,
      );
      expect(
        deriveOperationShift(SchoolShift.fullTime, RouteLeg.homebound),
        OperationShift.afternoon,
      );
    });

    test('an unknown period is read as full time', () {
      expect(
        deriveOperationShift(null, RouteLeg.outbound),
        OperationShift.morning,
      );
      expect(
        deriveOperationShift(null, RouteLeg.homebound),
        OperationShift.afternoon,
      );
    });
  });

  group('previewInstallmentAmount', () {
    test('divides the total by the installments', () {
      expect(previewInstallmentAmount(800000, 10), 80000);
    });

    test('drops the cents that do not divide, like the back', () {
      expect(previewInstallmentAmount(100000, 3), 33333);
    });

    test('a single installment is the total', () {
      expect(previewInstallmentAmount(744000, 1), 744000);
    });

    test('no installments has no preview', () {
      expect(previewInstallmentAmount(744000, 0), isNull);
    });
  });

  group('summarizeLegs', () {
    test('every day with both legs is a round trip', () {
      expect(
        summarizeLegs(roundTripOn(weekdaysMondayToFriday)),
        LegsSummary.roundTrip,
      );
    });

    test('only outbound legs', () {
      expect(
        summarizeLegs([
          for (final weekday in weekdaysMondayToFriday)
            TestRequestedDay(weekday: weekday, needsReturn: false),
        ]),
        LegsSummary.outboundOnly,
      );
    });

    test('only return legs', () {
      expect(
        summarizeLegs([
          for (final weekday in weekdaysMondayToFriday)
            TestRequestedDay(weekday: weekday, needsOutbound: false),
        ]),
        LegsSummary.homeboundOnly,
      );
    });

    test('a day with one leg among round trips is mixed', () {
      expect(
        summarizeLegs([
          ...roundTripOn([Weekday.monday, Weekday.tuesday]),
          const TestRequestedDay(
            weekday: Weekday.wednesday,
            needsReturn: false,
          ),
        ]),
        LegsSummary.mixed,
      );
    });

    test('days without legs are left out', () {
      expect(
        summarizeLegs([
          ...roundTripOn([Weekday.monday]),
          const TestRequestedDay(
            weekday: Weekday.tuesday,
            needsOutbound: false,
            needsReturn: false,
          ),
        ]),
        LegsSummary.roundTrip,
      );
    });

    test('no leg at all has no summary', () {
      expect(summarizeLegs([]), isNull);
    });
  });

  group('summarizeSlots', () {
    test('the slots of a proposal summarize like the requested days', () {
      expect(
        summarizeSlots(roundTripSlotsOn(weekdaysMondayToFriday)),
        LegsSummary.roundTrip,
      );
      expect(
        summarizeSlots([
          ...roundTripSlotsOn([Weekday.monday]),
          const TestScheduleSlot(
            weekday: Weekday.wednesday,
            leg: RouteLeg.outbound,
          ),
        ]),
        LegsSummary.mixed,
      );
      expect(
        summarizeSlots([
          const TestScheduleSlot(
            weekday: Weekday.friday,
            leg: RouteLeg.homebound,
          ),
        ]),
        LegsSummary.homeboundOnly,
      );
      expect(summarizeSlots([]), isNull);
    });
  });
}
