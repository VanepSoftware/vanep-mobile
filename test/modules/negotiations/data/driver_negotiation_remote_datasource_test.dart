import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/driver_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiation_json_fixtures.dart';
import '../negotiations_fixtures.dart';
import '../negotiations_mocks.dart';

const requestsUrl = 'http://10.0.2.2:8080/api/drivers/me/service-requests';
const proposalsUrl = 'http://10.0.2.2:8080/api/drivers/me/proposals';

void main() {
  late MockDio dio;
  late DriverNegotiationRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = DriverNegotiationRemoteDataSource(
      dio: dio,
      environment: testNegotiationsEnvironment,
    );
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => okResponse<Map<String, dynamic>>(
        pageJson([driverServiceRequestJson()]),
      ),
    );
  });

  void answerPost(Map<String, Object?> body) {
    when(() => dio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => okResponse<Map<String, dynamic>>(body));
  }

  test('lists the open requests in the driver view', () async {
    final page = await remote.listMyServiceRequests(
      statuses: {ServiceRequestStatus.open, ServiceRequestStatus.answered},
    );

    expect(page.items.single.clientFirstName, 'Maria');
    verify(
      () => dio.get<Map<String, dynamic>>(
        requestsUrl,
        queryParameters: {'status': 'OPEN,ANSWERED', 'page': 0},
      ),
    ).called(1);
  });

  test('declines a request with a reason', () async {
    answerPost(driverServiceRequestJson());

    await remote.declineServiceRequest('request-1', reason: 'Sem vaga.');

    verify(
      () => dio.post<Map<String, dynamic>>(
        '$requestsUrl/request-1/decline',
        data: {'reason': 'Sem vaga.'},
      ),
    ).called(1);
  });

  test('sends a proposal to the request it answers', () async {
    answerPost(proposalJson(dependentName: null));
    final draft = ProposalDraft.fromRequest(
      TestDriverServiceRequest(
        items: [
          TestDriverRequestItem(days: roundTripOn([Weekday.monday])),
        ],
      ),
    );

    final proposal = await remote.sendProposal(draft);

    expect(proposal.items.single.dependentName, isNull);
    verify(
      () => dio.post<Map<String, dynamic>>(
        '$requestsUrl/request-1/proposals',
        data: any(named: 'data'),
      ),
    ).called(1);
  });

  test('lists the versions, finds and withdraws a proposal', () async {
    when(() => dio.get<List<dynamic>>(any()))
        .thenAnswer((_) async => okResponse<List<dynamic>>([proposalJson()]));
    answerPost(proposalJson());

    await remote.listProposalVersions('request-1');
    await remote.withdrawProposal('proposal-v2');

    verify(() => dio.get<List<dynamic>>('$requestsUrl/request-1/proposals'))
        .called(1);
    verify(
      () => dio.post<Map<String, dynamic>>(
        '$proposalsUrl/proposal-v2/withdraw',
        data: any(named: 'data'),
      ),
    ).called(1);
  });

  test('finds a request and a proposal by token', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        '$requestsUrl/request-1',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => okResponse<Map<String, dynamic>>(driverServiceRequestJson()),
    );
    when(
      () => dio.get<Map<String, dynamic>>(
        '$proposalsUrl/proposal-v2',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => okResponse<Map<String, dynamic>>(proposalJson()));

    final request = await remote.findServiceRequest('request-1');
    final proposal = await remote.findProposal('proposal-v2');

    expect(request.token, 'request-1');
    expect(proposal.token, 'proposal-v2');
  });
}
