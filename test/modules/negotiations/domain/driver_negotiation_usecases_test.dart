import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/decline_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_proposal_versions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/send_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/withdraw_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiations_mocks.dart';

void main() {
  late MockDriverNegotiationRepository repository;
  final request = FakeDriverServiceRequest();
  final proposal = FakeProposal();
  final requestOk = Ok<NegotiationFailure, DriverServiceRequest>(request);
  final proposalOk = Ok<NegotiationFailure, Proposal>(proposal);

  setUpAll(registerNegotiationFallbackValues);

  setUp(() => repository = MockDriverNegotiationRepository());

  test('ListDriverServiceRequests lists a page of statuses', () async {
    final pageOk =
        Ok<NegotiationFailure, NegotiationPage<DriverServiceRequest>>(
          NegotiationPage(items: [request], isLast: true, totalElements: 1),
        );
    when(
      () => repository.listMyServiceRequests(
        statuses: {ServiceRequestStatus.open},
        conversationToken: null,
        page: 0,
      ),
    ).thenAnswer((_) async => pageOk);

    expect(
      await ListDriverServiceRequests(repository)(
        statuses: {ServiceRequestStatus.open},
      ),
      pageOk,
    );
  });

  test(
    'FindDriverServiceRequest and DeclineServiceRequest forward the token',
    () async {
      when(() => repository.findServiceRequest('request-1'))
          .thenAnswer((_) async => requestOk);
      when(
        () =>
            repository.declineServiceRequest('request-1', reason: 'Sem vaga.'),
      ).thenAnswer((_) async => requestOk);

      expect(
        await FindDriverServiceRequest(repository)('request-1'),
        requestOk,
      );
      expect(
        await DeclineServiceRequest(repository)(
          'request-1',
          reason: 'Sem vaga.',
        ),
        requestOk,
      );
    },
  );

  test('SendProposal sends the draft', () async {
    const draft = ProposalDraft(serviceRequestToken: 'request-1');
    when(() => repository.sendProposal(draft))
        .thenAnswer((_) async => proposalOk);

    expect(await SendProposal(repository)(draft), proposalOk);
  });

  test('ListDriverProposalVersions, FindDriverProposal and WithdrawProposal forward the token', () async {
    final chainOk = Ok<NegotiationFailure, List<Proposal>>([proposal]);
    when(() => repository.listProposalVersions('request-1'))
        .thenAnswer((_) async => chainOk);
    when(() => repository.findProposal('proposal-v2'))
        .thenAnswer((_) async => proposalOk);
    when(() => repository.withdrawProposal('proposal-v2'))
        .thenAnswer((_) async => proposalOk);

    expect(await ListDriverProposalVersions(repository)('request-1'), chainOk);
    expect(await FindDriverProposal(repository)('proposal-v2'), proposalOk);
    expect(await WithdrawProposal(repository)('proposal-v2'), proposalOk);
  });
}
