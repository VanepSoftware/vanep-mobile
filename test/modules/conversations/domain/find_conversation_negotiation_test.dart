import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/find_conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../conversations_mocks.dart';

void main() {
  late MockListClientServiceRequests listRequests;
  late MockListClientProposalVersions listVersions;
  late FindConversationNegotiation<ClientServiceRequest> findNegotiation;

  final latest = TestClientServiceRequest(
    token: 'request-2',
    status: ServiceRequestStatus.answered,
  );
  final older = TestClientServiceRequest(
    token: 'request-1',
    status: ServiceRequestStatus.withdrawn,
  );
  final version1 = TestProposal(
    status: ProposalStatus.superseded,
    adjustments: [TestProposalAdjustment(createdAt: DateTime.utc(2026, 10, 3))],
  );
  final version2 = TestProposal(
    token: 'proposal-v2',
    version: 2,
    createdAt: DateTime.utc(2026, 10, 4),
    acceptedAt: null,
  );

  void answerList(List<ClientServiceRequest> requests) {
    when(
      () =>
          listRequests(statuses: const {}, conversationToken: 'conversation-1'),
    ).thenAnswer(
      (_) async => Ok(
        NegotiationPage(
          items: requests,
          isLast: true,
          totalElements: requests.length,
        ),
      ),
    );
  }

  setUp(() {
    listRequests = MockListClientServiceRequests();
    listVersions = MockListClientProposalVersions();
    findNegotiation = FindConversationNegotiation(
      listRequests: listRequests.call,
      listVersions: listVersions.call,
    );
    when(() => listVersions('request-2'))
        .thenAnswer((_) async => Ok([version1, version2]));
  });

  test(
    'reads the latest negotiation of the conversation and its versions',
    () async {
      answerList([latest, older]);

      final result = await findNegotiation('conversation-1');

      expect(
        result.valueOrNull,
        ConversationNegotiation<ClientServiceRequest>(
          request: latest,
          versions: [version1, version2],
        ),
      );
    },
  );

  test('a conversation without a negotiation has none', () async {
    answerList([]);

    final result = await findNegotiation('conversation-1');

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isNull);
    verifyNever(() => listVersions(any()));
  });

  test('a failure reading the negotiation is returned', () async {
    when(
      () =>
          listRequests(statuses: const {}, conversationToken: 'conversation-1'),
    ).thenAnswer((_) async => const Err(NegotiationNetworkFailure()));

    final result = await findNegotiation('conversation-1');

    expect(result.errorOrNull, const NegotiationNetworkFailure());
  });

  test(
    'the conversation shows the request, the versions and the adjustments',
    () {
      final negotiation = ConversationNegotiation(
        request: TestClientServiceRequest(
          status: ServiceRequestStatus.converted,
        ),
        versions: [
          version1,
          TestProposal(
            token: 'proposal-v2',
            version: 2,
            status: ProposalStatus.accepted,
            createdAt: DateTime.utc(2026, 10, 4),
            acceptedAt: DateTime.utc(2026, 10, 5),
          ),
        ],
      );

      expect(negotiation.events.map((event) => event.runtimeType), [
        RequestSentEvent,
        ProposalSentEvent,
        AdjustmentRequestedEvent,
        ProposalSentEvent,
      ]);
      expect(negotiation.openProposal, isNull);
    },
  );

  test('the open version is the one the client can still answer', () {
    final negotiation = ConversationNegotiation(
      request: latest,
      versions: [version1, version2],
    );

    expect(negotiation.openProposal, version2);
  });

  test('the events are built once, not on every read', () {
    final negotiation = ConversationNegotiation(
      request: latest,
      versions: [version1, version2],
    );

    expect(identical(negotiation.events, negotiation.events), isTrue);
  });
}
