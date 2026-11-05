import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/client_proposals_scenario.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/dependent_proposal_children_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/empty_proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/datasources/scenario_client_proposals_datasource.dart';
import 'package:vanep_mobile/modules/client_proposals/data/repositories/client_proposals_repository_impl.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';

import '../../dependents/dependents_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  group('ClientProposalsScenario', () {
    test('resolves known names and ignores the rest', () {
      expect(
        ClientProposalsScenario.fromName(' singleChild '),
        ClientProposalsScenario.singleChild,
      );
      expect(ClientProposalsScenario.fromName(''), isNull);
      expect(ClientProposalsScenario.fromName('unknown'), isNull);
    });
  });

  test('the empty data source has no proposals', () async {
    expect(
      await const EmptyProposalsDataSource().findProposals(),
      const ProposalsFeed(),
    );
  });

  group('DependentProposalChildrenDataSource', () {
    late MockFindMyDependents findMyDependents;
    late DependentProposalChildrenDataSource dataSource;

    setUp(() {
      findMyDependents = MockFindMyDependents();
      dataSource = DependentProposalChildrenDataSource(
        findMyDependents: findMyDependents,
      );
    });

    test('maps every dependent to a child', () async {
      when(findMyDependents.call).thenAnswer(
        (_) async => const Ok<DependentFailure, List<Dependent>>([
          testHelenaDependent,
        ]),
      );

      expect(await dataSource.findChildren(), [
        ProposalChild(
          token: testHelenaDependent.token,
          name: testHelenaDependent.name,
          birthDate: testHelenaDependent.birthDate,
        ),
      ]);
    });

    test('throws with the failure when dependents fail', () async {
      when(findMyDependents.call).thenAnswer(
        (_) async => const Err<DependentFailure, List<Dependent>>(
          DependentNetworkFailure(),
        ),
      );

      await expectLater(
        dataSource.findChildren(),
        throwsA(
          isA<ProposalChildrenUnavailable>().having(
            (error) => error.isNetwork,
            'isNetwork',
            isTrue,
          ),
        ),
      );
    });
  });

  group('ScenarioClientProposalsDataSource', () {
    ScenarioClientProposalsDataSource scenarioFor(
      ClientProposalsScenario scenario,
    ) => ScenarioClientProposalsDataSource(
      scenario: scenario,
      clock: () => testProposalsNow,
    );

    test('openProposals mirrors the design', () async {
      final dataSource = scenarioFor(ClientProposalsScenario.openProposals);
      final feed = await dataSource.findProposals();
      final children = await dataSource.findChildren();

      expect(feed.pending, hasLength(2));
      expect(feed.awaiting, hasLength(1));
      expect(feed.closed, hasLength(2));
      expect(children.map((child) => child.name), [
        'Pedro',
        'Lucas',
        'Ana',
        'Bia',
        'Davi',
      ]);
    });

    test('singleChild has one child', () async {
      final dataSource = scenarioFor(ClientProposalsScenario.singleChild);

      expect(await dataSource.findChildren(), hasLength(1));
    });

    test('limitReached fills every open slot', () async {
      final feed = await scenarioFor(
        ClientProposalsScenario.limitReached,
      ).findProposals();

      expect(feed.openCount, openRequestsLimit);
    });

    test('every entry belongs to a scenario child', () async {
      for (final scenario in ClientProposalsScenario.values) {
        final dataSource = scenarioFor(scenario);
        final tokens = (await dataSource.findChildren()).map(
          (child) => child.token,
        );
        final feed = await dataSource.findProposals();
        final entries = [...feed.pending, ...feed.awaiting, ...feed.closed];

        expect(
          entries.every((entry) => tokens.contains(entry.childToken)),
          isTrue,
          reason: scenario.name,
        );
      }
    });
  });

  group('ClientProposalsRepositoryImpl', () {
    late MockProposalsDataSource proposalsDataSource;
    late MockProposalChildrenDataSource childrenDataSource;
    late ClientProposalsRepositoryImpl repository;

    setUp(() {
      proposalsDataSource = MockProposalsDataSource();
      childrenDataSource = MockProposalChildrenDataSource();
      repository = ClientProposalsRepositoryImpl(
        proposalsDataSource: proposalsDataSource,
        childrenDataSource: childrenDataSource,
      );
    });

    test('returns the proposals', () async {
      when(
        proposalsDataSource.findProposals,
      ).thenAnswer((_) async => testProposalsFeed);

      expect((await repository.findProposals()).valueOrNull, testProposalsFeed);
    });

    test('maps a proposals error to unexpected', () async {
      when(proposalsDataSource.findProposals).thenThrow(Exception('boom'));

      expect(
        (await repository.findProposals()).errorOrNull,
        ClientProposalsFailure.unexpected,
      );
    });

    test('returns the children', () async {
      when(
        childrenDataSource.findChildren,
      ).thenAnswer((_) async => const [testPedro]);

      expect((await repository.findChildren()).valueOrNull, [testPedro]);
    });

    test('maps a dependents network failure to network', () async {
      when(childrenDataSource.findChildren).thenThrow(
        const ProposalChildrenUnavailable(DependentNetworkFailure()),
      );

      expect(
        (await repository.findChildren()).errorOrNull,
        ClientProposalsFailure.network,
      );
    });

    test('maps other dependents failures to unexpected', () async {
      when(childrenDataSource.findChildren).thenThrow(
        const ProposalChildrenUnavailable(DependentUnexpectedFailure()),
      );

      expect(
        (await repository.findChildren()).errorOrNull,
        ClientProposalsFailure.unexpected,
      );
    });
  });
}
