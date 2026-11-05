import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_enabled_shortcuts.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_home_headline.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

import '../client_home_fixtures.dart';

void main() {
  group('PrioritizeNeedsYouItems', () {
    const prioritize = PrioritizeNeedsYouItems();

    test('puts the contract to sign before proposals and payments', () {
      final summary = prioritize([
        testAnaMonthlyFee,
        testRitaProposal,
        testContractToSign,
      ]);

      expect(summary.visible, [
        testContractToSign,
        testRitaProposal,
        testAnaMonthlyFee,
      ]);
      expect(summary.featured, testContractToSign);
    });

    test('orders by closest deadline inside a tier', () {
      final summary = prioritize([testRitaProposal, testCarlosProposal]);

      expect(summary.visible, [testCarlosProposal, testRitaProposal]);
    });

    test('items without a deadline come after dated ones in a tier', () {
      final summary = prioritize([testExpiredRequest, testRitaProposal]);

      expect(summary.visible, [testRitaProposal, testExpiredRequest]);
    });

    test('caps at three and counts the hidden ones', () {
      final summary = prioritize([
        testRenewal,
        testInspectionExpired,
        testRateCarlos,
        testAnaMonthlyFee,
        testContractToSign,
      ]);

      expect(summary.visible, hasLength(3));
      expect(summary.visible.first, testContractToSign);
      expect(summary.hiddenCount, 2);
      expect(summary.hasMore, isTrue);
    });

    test('a payment first is not featured and every item is a row', () {
      final summary = prioritize([testOctoberFeeAwaitingConfirmation]);

      expect(summary.featured, isNull);
      expect(summary.rows, [testOctoberFeeAwaitingConfirmation]);
    });

    test('an empty list gives an empty summary', () {
      expect(prioritize(const []).isEmpty, isTrue);
    });
  });

  group('ResolveEnabledShortcuts', () {
    const resolve = ResolveEnabledShortcuts();

    test('with a linked van every shortcut is enabled', () {
      expect(resolve(testBeforeRouteSection), HomeShortcut.values.toSet());
    });

    test('without a van only proposals is enabled', () {
      expect(resolve(testNegotiatingSection), {HomeShortcut.proposals});
      expect(
        resolve(
          const FirstStepsSection(hasAddress: false, hasDependents: false),
        ),
        {HomeShortcut.proposals},
      );
    });
  });

  group('ResolveHomeHeadline', () {
    const resolve = ResolveHomeHeadline();

    test('without a van it says hello', () {
      expect(
        resolve(today: testNegotiatingSection, now: testWednesdayMorning),
        HomeHeadline.hello,
      );
    });

    test('a van approaching the stop wins over the time of day', () {
      expect(
        resolve(
          today: testLiveSection(approaching: true),
          now: testWednesdayMorning,
        ),
        HomeHeadline.vanArriving,
      );
    });

    test('after the drop-off it says all good', () {
      expect(
        resolve(today: testArrivedSection, now: testWednesdayMorning),
        HomeHeadline.allGood,
      );
    });

    test('no route on a weekend wishes a good weekend', () {
      expect(
        resolve(today: testNoRouteTodaySection, now: testSaturdayMorning),
        HomeHeadline.goodWeekend,
      );
    });

    test('a route day greets by the time of day', () {
      expect(
        resolve(today: testBeforeRouteSection, now: atWednesday(9)),
        HomeHeadline.goodMorning,
      );
      expect(
        resolve(today: testBeforeRouteSection, now: atWednesday(14)),
        HomeHeadline.goodAfternoon,
      );
      expect(
        resolve(today: testBeforeRouteSection, now: atWednesday(20)),
        HomeHeadline.goodEvening,
      );
    });
  });

  group('FirstStepsSection', () {
    test('the account step is always done', () {
      const steps = FirstStepsSection(hasAddress: false, hasDependents: false);

      expect(steps.completedSteps, 1);
      expect(steps.currentStep, FirstStep.address);
    });

    test('with an address the current step is the dependents', () {
      const steps = FirstStepsSection(hasAddress: true, hasDependents: false);

      expect(steps.completedSteps, 2);
      expect(steps.currentStep, FirstStep.dependents);
    });

    test('with everything done there is no current step', () {
      const steps = FirstStepsSection(hasAddress: true, hasDependents: true);

      expect(steps.isComplete, isTrue);
    });
  });

  group('VanDaySection', () {
    test('the van leaving first is expanded and the rest collapse', () {
      final section = VanDaySection(
        vans: [testRitaAfternoonVan, testCarlosMorningVan],
      );

      expect(section.expandedVan, testCarlosMorningVan);
      expect(section.collapsedVans, [testRitaAfternoonVan]);
    });

    test('a live van is expanded even when another leaves earlier', () {
      final liveAfternoon = VanDay(
        driverName: testRitaAfternoonVan.driverName,
        vehicleModel: testRitaAfternoonVan.vehicleModel,
        plate: testRitaAfternoonVan.plate,
        shift: testRitaAfternoonVan.shift,
        departureAt: testRitaAfternoonVan.departureAt,
        riders: testRitaAfternoonVan.riders,
        schedule: testRitaAfternoonVan.schedule,
        live: testLiveTrip(),
      );
      final section = VanDaySection(
        vans: [testCarlosMorningVan, liveAfternoon],
      );

      expect(section.expandedVan, liveAfternoon);
    });
  });

  group('NoRouteTodaySection', () {
    test('finds the first day the child only goes', () {
      expect(
        testNoRouteTodaySection.firstDayWithoutReturn?.date,
        DateTime(2026, 10, 21),
      );
    });
  });
}
