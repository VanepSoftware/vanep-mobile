import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/find_negotiation_highlights.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/negotiation_highlights.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../client_home_mocks.dart';

void main() {
  late MockListClientServiceRequests listServiceRequests;
  late FindNegotiationHighlights findHighlights;

  final now = DateTime(2026, 10, 25, 10);

  TestClientRequestItem itemOf(String token, String name) =>
      TestClientRequestItem(dependentToken: token, dependentName: name);

  final proposalForSiblings = TestClientServiceRequest(
    token: 'request-carlos',
    status: ServiceRequestStatus.answered,
    items: [itemOf('ana', 'Ana Souza'), itemOf('pedro', 'Pedro Souza')],
    currentProposal: TestProposalSummary(
      validUntil: now.add(const Duration(days: 6)),
    ),
  );
  final adjustmentAsked = TestClientServiceRequest(
    token: 'request-rita',
    status: ServiceRequestStatus.answered,
    items: [itemOf('pedro', 'Pedro Souza')],
    currentProposal: TestProposalSummary(hasPendingAdjustment: true),
  );
  final waitingForDriver = TestClientServiceRequest(
    token: 'request-joao',
    items: [itemOf('lucas', 'Lucas Souza')],
  );

  TestClientServiceRequest expiredAgo(Duration ago, String driverName) {
    return TestClientServiceRequest(
      token: 'expired-$driverName',
      status: ServiceRequestStatus.expired,
      driverName: driverName,
      updatedAt: now.subtract(ago).toUtc(),
    );
  }

  void answer(
    Set<ServiceRequestStatus> statuses,
    Result<NegotiationFailure, NegotiationPage<ClientServiceRequest>> result,
  ) {
    when(() => listServiceRequests(statuses: statuses))
        .thenAnswer((_) async => result);
  }

  Ok<NegotiationFailure, NegotiationPage<ClientServiceRequest>> pageOf(
    List<ClientServiceRequest> items,
  ) {
    return Ok(
      NegotiationPage(items: items, isLast: true, totalElements: items.length),
    );
  }

  setUp(() {
    listServiceRequests = MockListClientServiceRequests();
    findHighlights = FindNegotiationHighlights(
      listServiceRequests: listServiceRequests,
      clock: () => now,
    );
    answer(
      openServiceRequestStatuses,
      pageOf([proposalForSiblings, adjustmentAsked, waitingForDriver]),
    );
    answer(
      {ServiceRequestStatus.expired},
      pageOf([
        expiredAgo(const Duration(days: 6), 'Marta Dias'),
        expiredAgo(const Duration(days: 8), 'Paula Reis'),
      ]),
    );
  });

  test('a proposal waiting for the client becomes a new proposal', () async {
    final highlights = await findHighlights();

    expect(highlights.newProposals, [
      NewProposalItem(request: proposalForSiblings),
    ]);
  });

  test(
    'a request expired in the last 7 days stays, an older one goes',
    () async {
      final highlights = await findHighlights();

      expect(highlights.expiredRequests, [
        const ExpiredRequestItem(driverName: 'Marta Dias'),
      ]);
    },
  );

  test('counts the open negotiations and names their children', () async {
    final highlights = await findHighlights();

    expect(highlights.openCount, 3);
    expect(highlights.childNames, ['Ana Souza', 'Pedro Souza', 'Lucas Souza']);
  });

  test('a failure while reading is no highlight at all', () async {
    answer({
      ServiceRequestStatus.expired,
    }, const Err(NegotiationNetworkFailure()));

    expect(await findHighlights(), NegotiationHighlights.none);
  });
}
