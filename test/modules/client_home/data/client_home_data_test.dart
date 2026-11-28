import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_home/client_home_container.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/client_home_scenario.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/scenario_daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/repositories/client_home_repository_impl.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';

import '../client_home_fixtures.dart';
import '../client_home_mocks.dart';

void main() {
  group('ClientHomeRepositoryImpl', () {
    late MockDailyOverviewDataSource dataSource;

    setUp(() => dataSource = MockDailyOverviewDataSource());

    test('returns the overview from the data source', () async {
      when(
        dataSource.findDailyOverview,
      ).thenAnswer((_) async => DailyOverview(today: testBeforeRouteSection));

      final result = await ClientHomeRepositoryImpl(dataSource: dataSource)
          .findDailyOverview();

      expect(result.valueOrNull?.today, testBeforeRouteSection);
    });

    test('an unexpected error becomes an unexpected failure', () async {
      when(dataSource.findDailyOverview).thenThrow(StateError('broken'));

      final result = await ClientHomeRepositoryImpl(dataSource: dataSource)
          .findDailyOverview();

      expect(result.errorOrNull, ClientHomeFailure.unexpected);
    });
  });

  group('dailyOverviewDataSourceFor', () {
    test('without a scenario production reads the API', () {
      final remote = MockDailyOverviewDataSource();

      expect(dailyOverviewDataSourceFor('', remote: remote), same(remote));
    });

    test('a known scenario uses the scenario source', () {
      expect(
        dailyOverviewDataSourceFor(
          'beforeRoute',
          remote: MockDailyOverviewDataSource(),
        ),
        isA<ScenarioDailyOverviewDataSource>(),
      );
    });
  });

  group('ClientHomeScenario', () {
    test('parses known names and ignores the rest', () {
      expect(
        ClientHomeScenario.fromName('vanArriving'),
        ClientHomeScenario.vanArriving,
      );
      expect(ClientHomeScenario.fromName(''), isNull);
      expect(ClientHomeScenario.fromName('unknown'), isNull);
    });
  });

  group('ScenarioDailyOverviewDataSource', () {
    Future<DailyOverview> overviewFor(ClientHomeScenario scenario) {
      return ScenarioDailyOverviewDataSource(
        scenario: scenario,
        clock: () => testWednesdayMorning,
      ).findDailyOverview();
    }

    test('first access leaves the section to real data', () async {
      final overview = await overviewFor(ClientHomeScenario.firstAccess);

      expect(overview.today, isNull);
    });

    test('negotiating leaves the negotiations to the API', () async {
      final overview = await overviewFor(ClientHomeScenario.negotiating);

      expect(overview.today, isNull);
      expect(overview.needsYou, isEmpty);
    });

    test('no scenario mocks a negotiation anymore', () async {
      for (final scenario in ClientHomeScenario.values) {
        final overview = await overviewFor(scenario);

        expect(overview.today, isNot(isA<NegotiatingSection>()));
        expect(overview.needsYou.whereType<NewProposalItem>(), isEmpty);
        expect(overview.needsYou.whereType<ExpiredRequestItem>(), isEmpty);
      }
    });

    test('everything at once has a live van and a contract to sign', () async {
      final overview = await overviewFor(ClientHomeScenario.everythingAtOnce);
      final today = overview.today! as VanDaySection;

      expect(today.liveVan?.riders.map((rider) => rider.name), ['Ana']);
      expect(today.childrenWithoutRoute, isEmpty);
      expect(today.isVanApproaching, isFalse);
      expect(overview.needsYou.whereType<ContractToSignItem>(), isNotEmpty);
    });

    test('before route has two vans and children without route', () async {
      final overview = await overviewFor(ClientHomeScenario.beforeRoute);
      final today = overview.today! as VanDaySection;

      expect(today.vans, hasLength(2));
      expect(today.childrenWithoutRoute.single.name, 'Bia');
    });

    test('van arriving is approaching with the child day', () async {
      final overview = await overviewFor(ClientHomeScenario.vanArriving);
      final today = overview.today! as VanDaySection;

      expect(today.isVanApproaching, isTrue);
      expect(today.childDay, isNotNull);
    });

    test('arrived at school lists the events of the day', () async {
      final overview = await overviewFor(ClientHomeScenario.arrivedAtSchool);

      expect((overview.today! as ArrivedSection).events, hasLength(4));
    });

    test('no route today only mocks the needs-you items', () async {
      final overview = await overviewFor(ClientHomeScenario.noRouteToday);

      expect(overview.today, isNull);
      expect(overview.needsYou, hasLength(1));
      expect(
        overview.needsYou.whereType<VehicleInspectionExpiredItem>(),
        isEmpty,
      );
      expect(overview.needsYou.whereType<RateDriverItem>(), isEmpty);
    });
  });
}
