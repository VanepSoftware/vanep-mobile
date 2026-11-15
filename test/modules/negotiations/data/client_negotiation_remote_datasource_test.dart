import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/client_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiation_json_fixtures.dart';
import '../negotiations_mocks.dart';

const requestsUrl = 'http://10.0.2.2:8080/api/clients/me/service-requests';
const proposalsUrl = 'http://10.0.2.2:8080/api/clients/me/proposals';

void main() {
  late MockDio dio;
  late ClientNegotiationRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = ClientNegotiationRemoteDataSource(
      dio: dio,
      environment: testNegotiationsEnvironment,
    );
  });

  void answerPost(Map<String, Object?> body) {
    when(() => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => okResponse<Map<String, dynamic>>(body));
  }

  void answerGet(Object body) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async =>
          okResponse<Map<String, dynamic>>(body as Map<String, dynamic>),
    );
  }

  test('sends a request to the client surface', () async {
    answerPost(clientServiceRequestJson(status: 'OPEN'));
    final draft = ServiceRequestDraft(
      driverToken: 'driver-carlos',
      desiredStartDate: DateTime(2027, 2, 1),
    ).withStudent('dep-theo', [Weekday.monday]);

    final request = await remote.sendServiceRequest(draft);

    expect(request.token, 'request-1');
    final body =
        verify(
              () => dio.post<Map<String, dynamic>>(
                requestsUrl,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, Object?>;
    expect(body['driverToken'], 'driver-carlos');
  });

  test('lists the requests of some statuses and a conversation', () async {
    answerGet(
      pageJson([clientServiceRequestJson()], last: false, totalElements: 21),
    );

    final page = await remote.listMyServiceRequests(
      statuses: {ServiceRequestStatus.answered, ServiceRequestStatus.open},
      conversationToken: 'conversation-1',
      page: 1,
    );

    expect(page.items.single.token, 'request-1');
    expect(page.isLast, isFalse);
    expect(page.totalElements, 21);
    verify(
      () => dio.get<Map<String, dynamic>>(
        requestsUrl,
        queryParameters: {
          'status': 'OPEN,ANSWERED',
          'conversationToken': 'conversation-1',
          'page': 1,
        },
      ),
    ).called(1);
  });

  test('lists every status without a filter', () async {
    answerGet(pageJson([]));

    final page = await remote.listMyServiceRequests(statuses: {});

    expect(page.items, isEmpty);
    expect(page.isLast, isTrue);
    verify(
      () => dio.get<Map<String, dynamic>>(
        requestsUrl,
        queryParameters: {'page': 0},
      ),
    ).called(1);
  });

  test('finds a request by its token', () async {
    answerGet(clientServiceRequestJson());

    await remote.findServiceRequest('request 1');

    verify(
      () => dio.get<Map<String, dynamic>>(
        '$requestsUrl/request%201',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
  });

  test('withdraws a request', () async {
    answerPost(clientServiceRequestJson(status: 'WITHDRAWN'));

    await remote.withdrawServiceRequest('request-1');

    verify(
      () => dio.post<Map<String, dynamic>>(
        '$requestsUrl/request-1/withdraw',
        data: any(named: 'data'),
      ),
    ).called(1);
  });

  test('lists the versions of a request oldest first', () async {
    when(() => dio.get<List<dynamic>>(any())).thenAnswer(
      (_) async => okResponse<List<dynamic>>([proposalJson(), proposalJson()]),
    );

    final versions = await remote.listProposalVersions('request-1');

    expect(versions, hasLength(2));
    verify(() => dio.get<List<dynamic>>('$requestsUrl/request-1/proposals'))
        .called(1);
  });

  test('finds, accepts and declines a proposal', () async {
    answerGet(proposalJson());
    answerPost(proposalJson());

    await remote.findProposal('proposal-v2');
    await remote.acceptProposal('proposal-v2');
    await remote.declineProposal('proposal-v2', reason: 'Escolhi outra van.');

    verify(
      () => dio.get<Map<String, dynamic>>(
        '$proposalsUrl/proposal-v2',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
    verify(
      () => dio.post<Map<String, dynamic>>(
        '$proposalsUrl/proposal-v2/accept',
        data: any(named: 'data'),
      ),
    ).called(1);
    verify(
      () => dio.post<Map<String, dynamic>>(
        '$proposalsUrl/proposal-v2/decline',
        data: {'reason': 'Escolhi outra van.'},
      ),
    ).called(1);
  });

  test('asks for an adjustment', () async {
    answerPost(proposalJson());

    await remote.requestProposalAdjustment(
      'proposal-v2',
      const ProposalAdjustmentDraft(
        field: ProposalAdjustmentField.price,
        suggestedValue: 'R\$ 290',
      ),
    );

    verify(
      () => dio.post<Map<String, dynamic>>(
        '$proposalsUrl/proposal-v2/adjustments',
        data: {'field': 'PRICE', 'suggestedValue': 'R\$ 290'},
      ),
    ).called(1);
  });

  test('an empty answer is unreadable', () async {
    when(() => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => okResponse<Map<String, dynamic>>(null));

    expect(() => remote.acceptProposal('proposal-v2'), throwsFormatException);
  });
}
