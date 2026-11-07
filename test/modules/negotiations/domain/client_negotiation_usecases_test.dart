import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/accept_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/request_proposal_adjustment.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiations_mocks.dart';

void main() {
  late MockClientNegotiationRepository repository;
  final request = FakeClientServiceRequest();
  final proposal = FakeProposal();
  final requestOk = Ok<NegotiationFailure, ClientServiceRequest>(request);
  final proposalOk = Ok<NegotiationFailure, Proposal>(proposal);

  setUpAll(registerNegotiationFallbackValues);

  setUp(() => repository = MockClientNegotiationRepository());

  test('SendServiceRequest sends the draft', () async {
    const draft = ServiceRequestDraft(driverToken: 'driver-carlos');
    when(() => repository.sendServiceRequest(draft))
        .thenAnswer((_) async => requestOk);

    expect(await SendServiceRequest(repository)(draft), requestOk);
  });

  test('ListClientServiceRequests lists a page of statuses', () async {
    final pageOk =
        Ok<NegotiationFailure, NegotiationPage<ClientServiceRequest>>(
          NegotiationPage(items: [request], isLast: true, totalElements: 1),
        );
    when(
      () => repository.listMyServiceRequests(
        statuses: {ServiceRequestStatus.expired},
        conversationToken: 'conversation-1',
        page: 2,
      ),
    ).thenAnswer((_) async => pageOk);

    final result = await ListClientServiceRequests(repository)(
      statuses: {ServiceRequestStatus.expired},
      conversationToken: 'conversation-1',
      page: 2,
    );

    expect(result, pageOk);
  });

  test(
    'FindClientServiceRequest and WithdrawServiceRequest forward the token',
    () async {
      when(() => repository.findServiceRequest('request-1'))
          .thenAnswer((_) async => requestOk);
      when(() => repository.withdrawServiceRequest('request-1'))
          .thenAnswer((_) async => requestOk);

      expect(
        await FindClientServiceRequest(repository)('request-1'),
        requestOk,
      );
      expect(await WithdrawServiceRequest(repository)('request-1'), requestOk);
    },
  );

  test('ListClientProposalVersions reads the chain of a request', () async {
    final chainOk = Ok<NegotiationFailure, List<Proposal>>([proposal]);
    when(() => repository.listProposalVersions('request-1'))
        .thenAnswer((_) async => chainOk);

    expect(await ListClientProposalVersions(repository)('request-1'), chainOk);
  });

  test(
    'FindClientProposal, AcceptProposal and DeclineProposal forward the token',
    () async {
      when(() => repository.findProposal('proposal-v2'))
          .thenAnswer((_) async => proposalOk);
      when(() => repository.acceptProposal('proposal-v2'))
          .thenAnswer((_) async => proposalOk);
      when(
        () => repository.declineProposal('proposal-v2', reason: 'Outra van.'),
      ).thenAnswer((_) async => proposalOk);

      expect(await FindClientProposal(repository)('proposal-v2'), proposalOk);
      expect(await AcceptProposal(repository)('proposal-v2'), proposalOk);
      expect(
        await DeclineProposal(repository)('proposal-v2', reason: 'Outra van.'),
        proposalOk,
      );
    },
  );

  test('RequestProposalAdjustment sends the adjustment draft', () async {
    const draft = ProposalAdjustmentDraft(note: 'Pode buscar mais cedo?');
    when(() => repository.requestProposalAdjustment('proposal-v2', draft))
        .thenAnswer((_) async => proposalOk);

    expect(
      await RequestProposalAdjustment(repository)('proposal-v2', draft),
      proposalOk,
    );
  });
}
