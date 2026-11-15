import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_client_proposals.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockListClientServiceRequests listServiceRequests;
  late MockFindMyDependents findMyDependents;
  late LoadClientProposals loadClientProposals;

  void answerList(
    Set<ServiceRequestStatus> statuses,
    Result<NegotiationFailure, NegotiationPage<ClientServiceRequest>> result,
  ) {
    when(() => listServiceRequests(statuses: statuses))
        .thenAnswer((_) async => result);
  }

  setUp(() {
    listServiceRequests = MockListClientServiceRequests();
    findMyDependents = MockFindMyDependents();
    loadClientProposals = LoadClientProposals(
      listServiceRequests: listServiceRequests,
      findMyDependents: findMyDependents,
      clock: () => testProposalsNow,
    );
    answerList(
      openServiceRequestStatuses,
      Ok(
        NegotiationPage(
          items: testOpenRequests,
          isLast: true,
          totalElements: 4,
        ),
      ),
    );
    answerList(
      closedServiceRequestStatuses,
      Ok(
        NegotiationPage(
          items: [testClosedForPedro, testClosedForAna],
          isLast: false,
          totalElements: 25,
        ),
      ),
    );
    when(findMyDependents.call)
        .thenAnswer((_) async => const Ok([testPedro, testAna, testLucas]));
  });

  test('loads the open ones, the first closed page and the children', () async {
    final result = await loadClientProposals();

    expect(
      result.valueOrNull,
      testClientProposals(closedCount: 25, hasMoreClosed: true),
    );
  });

  test('a negotiation list without connection is a network failure', () async {
    answerList(
      closedServiceRequestStatuses,
      const Err(NegotiationNetworkFailure()),
    );

    final result = await loadClientProposals();

    expect(result.errorOrNull, ClientProposalsFailure.network);
  });

  test('the children without connection is a network failure', () async {
    when(findMyDependents.call)
        .thenAnswer((_) async => const Err(DependentNetworkFailure()));

    final result = await loadClientProposals();

    expect(result.errorOrNull, ClientProposalsFailure.network);
  });

  test('any other failure is unexpected', () async {
    answerList(
      openServiceRequestStatuses,
      const Err(NegotiationUnexpectedFailure()),
    );

    final result = await loadClientProposals();

    expect(result.errorOrNull, ClientProposalsFailure.unexpected);
  });
}
