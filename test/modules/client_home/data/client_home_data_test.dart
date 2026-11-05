import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_home/client_home_container.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/client_home_scenario.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/empty_daily_overview_datasource.dart';
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

      final result = await ClientHomeRepositoryImpl(
        dataSource: dataSource,
      ).findDailyOverview();

      expect(result.valueOrNull?.today, testBeforeRouteSection);
    });

    test('an unexpected error becomes an unexpected failure', () async {
      when(dataSource.findDailyOverview).thenThrow(StateError('broken'));

      final result = await ClientHomeRepositoryImpl(
        dataSource: dataSource,
      ).findDailyOverview();

      expect(result.errorOrNull, ClientHomeFailure.unexpected);
    });
  });

  test('the empty data source has no section and nothing pending', () async {
    final overview = await const EmptyDailyOverviewDataSource()
        .findDailyOverview();

    expect(overview, const DailyOverview());
  });

  group('dailyOverviewDataSourceFor', () {
    test('an empty scenario keeps production on the empty source', () {
      expect(
        dailyOverviewDataSourceFor(''),
        isA<EmptyDailyOverviewDataSource>(),
      );
    });

    test('a known scenario uses the scenario source', () {
      expect(
        dailyOverviewDataSourceFor('beforeRoute'),
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

    test('negotiating has the section and a new proposal', () async {
      final overview = await overviewFor(ClientHomeScenario.negotiating);

      expect(overview.today, isA<NegotiatingSection>());
      expect(overview.needsYou.whereType<NewProposalItem>(), isNotEmpty);
    });

    test('everything at once has a live van and a contract to sign', () async {
      final overview = await overviewFor(ClientHomeScenario.everythingAtOnce);
      final today = overview.today! as VanDaySection;

      expect(today.liveVan?.riders.map((rider) => rider.name), ['Ana']);
      expect(today.childrenWithoutRoute.single.name, 'Pedro');
      expect(today.isVanApproaching, isFalse);
      expect(overview.needsYou.whereType<ContractToSignItem>(), isNotEmpty);
    });

    test('before route has two vans and children without route', () async {
      final overview = await overviewFor(ClientHomeScenario.beforeRoute);
      final today = overview.today! as VanDaySection;

      expect(today.vans, hasLength(2));
      expect(today.childrenWithoutRoute, hasLength(2));
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

    test('no route today starts on the next weekday', () async {
      final overview = await overviewFor(ClientHomeScenario.noRouteToday);
      final today = overview.today! as NoRouteTodaySection;

      expect(today.week, hasLength(5));
      expect(today.nextRouteAt.weekday, DateTime.thursday);
      expect(overview.needsYou, hasLength(3));
    });
  });
}
