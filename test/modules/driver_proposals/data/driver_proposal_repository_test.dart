import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/data/datasources/scenario_proposal_compose_datasource.dart';
import 'package:vanep_mobile/modules/driver_proposals/data/repositories/driver_proposal_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/failures/driver_proposal_failure.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';

import '../driver_proposals_fixtures.dart';

class MockProposalComposeDataSource extends Mock
    implements ProposalComposeDataSource {}

void main() {
  late MockProposalComposeDataSource dataSource;
  late DriverProposalRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(testProposalComposeDraft());
  });

  setUp(() {
    dataSource = MockProposalComposeDataSource();
    repository = DriverProposalRepositoryImpl(dataSource: dataSource);
  });

  test('an empty scenario name opens the sample family', () async {
    final draft = await const ScenarioProposalComposeDataSource().loadCompose();

    expect(driverProposalScenarioFromName(''), isNull);
    expect(draft.familyName, 'Família Silva');
    expect(draft.students, hasLength(2));
    expect(draft.commissionCents, 500);
    expect(draft.block, ProposalComposeBlock.none);
    expect(draft.schedule, hasLength(10));
    expect(draft.conditions.dueDay, 10);
  });

  test('overdue and closed scenarios set the gate on the draft', () async {
    final overdue = await const ScenarioProposalComposeDataSource(
      scenario: DriverProposalScenario.overdueInvoice,
    ).loadCompose();
    final closed = await const ScenarioProposalComposeDataSource(
      scenario: DriverProposalScenario.notAcceptingStudents,
    ).loadCompose();

    expect(overdue.block, ProposalComposeBlock.overdueInvoice);
    expect(closed.block, ProposalComposeBlock.notAcceptingStudents);
  });

  test('a failed scenario becomes an unexpected failure', () async {
    final result = await const DriverProposalRepositoryImpl(
      dataSource: ScenarioProposalComposeDataSource(
        scenario: DriverProposalScenario.loadFailed,
      ),
    ).loadCompose();

    expect(
      result,
      const Err<DriverProposalFailure, ProposalComposeDraft>(
        DriverProposalFailure.unexpected,
      ),
    );
  });

  test('a network error stays a network failure', () async {
    when(dataSource.loadCompose).thenThrow(
      const ProposalComposeUnavailable(isNetwork: true),
    );

    final result = await repository.loadCompose();

    expect(
      result,
      const Err<DriverProposalFailure, ProposalComposeDraft>(
        DriverProposalFailure.network,
      ),
    );
  });

  test('send returns ok when the source accepts the draft', () async {
    final draft = testProposalComposeDraft();
    when(() => dataSource.send(draft)).thenAnswer((_) async {});

    final result = await repository.send(draft);

    expect(result, const Ok<DriverProposalFailure, void>(null));
  });
}
