import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/load_client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_enabled_shortcuts.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_home_headline.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/resolve_section_without_van.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';

import '../../auth/personal_address_fixture.dart';
import '../../auth/presentation/auth_presentation_mocks.dart';
import '../../dependents/dependents_fixtures.dart';
import '../../dependents/dependents_mocks.dart';
import '../client_home_fixtures.dart';
import '../client_home_mocks.dart';

void main() {
  group('ResolveSectionWithoutVan', () {
    late MockFindMyPersonalAddress findMyPersonalAddress;
    late MockFindMyDependents findMyDependents;

    setUp(() {
      findMyPersonalAddress = MockFindMyPersonalAddress();
      findMyDependents = MockFindMyDependents();
    });

    ResolveSectionWithoutVan buildUseCase() => ResolveSectionWithoutVan(
      findMyPersonalAddress: findMyPersonalAddress,
      findMyDependents: findMyDependents,
    );

    void addressReturns(PersonalAddress? address) {
      when(findMyPersonalAddress.call).thenAnswer(
        (_) async => Ok<PersonalAddressFailure, PersonalAddress?>(address),
      );
    }

    void dependentsReturn(List<Dependent> dependents) {
      when(findMyDependents.call).thenAnswer(
        (_) async => Ok<DependentFailure, List<Dependent>>(dependents),
      );
    }

    test('without address nor dependents it starts the first steps', () async {
      addressReturns(null);
      dependentsReturn(const []);

      final result = await buildUseCase()();

      expect(
        result.valueOrNull,
        const FirstStepsSection(hasAddress: false, hasDependents: false),
      );
    });

    test('with address but no dependents the steps continue', () async {
      addressReturns(fakePersonalAddress());
      dependentsReturn(const []);

      final result = await buildUseCase()();

      expect(
        result.valueOrNull,
        const FirstStepsSection(hasAddress: true, hasDependents: false),
      );
    });

    test('with everything ready it falls back to no linked van', () async {
      addressReturns(fakePersonalAddress());
      dependentsReturn([testHelenaDependent]);

      final result = await buildUseCase()();

      expect(result.valueOrNull, const NoLinkedVanSection());
    });

    test('a network failure on the address is a network failure', () async {
      when(findMyPersonalAddress.call).thenAnswer(
        (_) async => const Err<PersonalAddressFailure, PersonalAddress?>(
          PersonalAddressFailure.network,
        ),
      );
      dependentsReturn(const []);

      final result = await buildUseCase()();

      expect(result.errorOrNull, ClientHomeFailure.network);
    });

    test('an unexpected dependents failure is unexpected', () async {
      addressReturns(null);
      when(findMyDependents.call).thenAnswer(
        (_) async => const Err<DependentFailure, List<Dependent>>(
          DependentUnexpectedFailure(),
        ),
      );

      final result = await buildUseCase()();

      expect(result.errorOrNull, ClientHomeFailure.unexpected);
    });
  });

  group('LoadClientHome', () {
    late MockClientHomeRepository repository;
    late MockResolveSectionWithoutVan resolveSectionWithoutVan;

    setUp(() {
      repository = MockClientHomeRepository();
      resolveSectionWithoutVan = MockResolveSectionWithoutVan();
    });

    LoadClientHome buildUseCase() => LoadClientHome(
      repository: repository,
      resolveSectionWithoutVan: resolveSectionWithoutVan,
      prioritizeNeedsYouItems: const PrioritizeNeedsYouItems(),
      resolveEnabledShortcuts: const ResolveEnabledShortcuts(),
      resolveHomeHeadline: const ResolveHomeHeadline(),
      clock: () => testWednesdayMorning,
    );

    void overviewReturns(DailyOverview overview) {
      when(
        repository.findDailyOverview,
      ).thenAnswer((_) async => Ok<ClientHomeFailure, DailyOverview>(overview));
    }

    test('uses the section from the overview when there is one', () async {
      overviewReturns(
        DailyOverview(
          today: testBeforeRouteSection,
          needsYou: [testOctoberFeeAwaitingConfirmation],
        ),
      );

      final home = (await buildUseCase()()).valueOrNull!;

      expect(home.today, testBeforeRouteSection);
      expect(home.headline, HomeHeadline.goodMorning);
      expect(home.enabledShortcuts, HomeShortcut.values.toSet());
      expect(home.needsYou.visible, [testOctoberFeeAwaitingConfirmation]);
      expect(home.date, testWednesdayMorning);
      verifyNever(resolveSectionWithoutVan.call);
    });

    test('without a section it resolves first steps from real data', () async {
      overviewReturns(const DailyOverview());
      when(resolveSectionWithoutVan.call).thenAnswer(
        (_) async => const Ok<ClientHomeFailure, TodaySection>(
          FirstStepsSection(hasAddress: false, hasDependents: false),
        ),
      );

      final home = (await buildUseCase()()).valueOrNull!;

      expect(home.today, isA<FirstStepsSection>());
      expect(home.headline, HomeHeadline.hello);
      expect(home.enabledShortcuts, {HomeShortcut.proposals});
    });

    test('prioritizes and caps the pending items', () async {
      overviewReturns(
        DailyOverview(
          today: testNoRouteTodaySection,
          needsYou: [
            testRateCarlos,
            testRenewal,
            testInspectionExpired,
            testAnaMonthlyFee,
          ],
        ),
      );

      final home = (await buildUseCase()()).valueOrNull!;

      expect(home.needsYou.visible.first, testAnaMonthlyFee);
      expect(home.needsYou.hiddenCount, 1);
    });

    test('an overview failure is returned as is', () async {
      when(repository.findDailyOverview).thenAnswer(
        (_) async => const Err<ClientHomeFailure, DailyOverview>(
          ClientHomeFailure.network,
        ),
      );

      final result = await buildUseCase()();

      expect(result.errorOrNull, ClientHomeFailure.network);
    });

    test('a failure resolving the section is returned as is', () async {
      overviewReturns(const DailyOverview());
      when(resolveSectionWithoutVan.call).thenAnswer(
        (_) async => const Err<ClientHomeFailure, TodaySection>(
          ClientHomeFailure.unexpected,
        ),
      );

      final result = await buildUseCase()();

      expect(result.errorOrNull, ClientHomeFailure.unexpected);
    });
  });
}
