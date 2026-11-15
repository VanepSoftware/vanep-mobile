import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/proposal_dto.dart';
import 'package:vanep_mobile/modules/negotiations/data/dtos/service_request_dto.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/client_negotiation_repository_impl.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/driver_negotiation_repository_impl.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/negotiation_call_guard.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiation_json_fixtures.dart';
import '../negotiations_mocks.dart';

void main() {
  setUpAll(registerNegotiationFallbackValues);

  group('the failures of a negotiation call', () {
    Future<NegotiationFailure?> failureOf(Object error) async {
      final result = await guardNegotiationCall<void>(() async => throw error);
      return result.errorOrNull;
    }

    test('no answer is a network failure', () async {
      expect(
        await failureOf(dioFailure(null)),
        const NegotiationNetworkFailure(),
      );
    });

    test('404 is not found', () async {
      expect(
        await failureOf(dioFailure(404)),
        const NegotiationNotFoundFailure(),
      );
    });

    test('409 is a conflict with the detail of the back', () async {
      expect(
        await failureOf(
          dioFailure(409, body: {'detail': 'A versão 2 chegou.'}),
        ),
        const NegotiationConflictFailure(detail: 'A versão 2 chegou.'),
      );
    });

    test('422 is a rejection with the detail of the back', () async {
      expect(
        await failureOf(dioFailure(422, body: {'detail': 'Limite de 5.'})),
        const NegotiationRejectedFailure(detail: 'Limite de 5.'),
      );
    });

    test('400 is invalid data', () async {
      expect(
        await failureOf(dioFailure(400)),
        const NegotiationInvalidFailure(),
      );
    });

    test('any other status or an unreadable answer is unexpected', () async {
      expect(
        await failureOf(dioFailure(500)),
        const NegotiationUnexpectedFailure(),
      );
      expect(
        await failureOf(const FormatException('Unreadable request status.')),
        const NegotiationUnexpectedFailure(),
      );
    });
  });

  test('the client repository returns what the datasource read', () async {
    final remote = MockClientNegotiationRemoteDataSource();
    final repository = ClientNegotiationRepositoryImpl(remote: remote);
    final request = ClientServiceRequestDto.fromJson(
      clientServiceRequestJson(),
    );
    when(
      () => remote.listMyServiceRequests(
        statuses: any(named: 'statuses'),
        conversationToken: any(named: 'conversationToken'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async =>
          NegotiationPage(items: [request], isLast: true, totalElements: 1),
    );
    when(() => remote.acceptProposal(any()))
        .thenThrow(dioFailure(409, body: {'detail': 'O cadastro mudou.'}));

    final page = await repository.listMyServiceRequests(
      statuses: {ServiceRequestStatus.open},
      conversationToken: 'conversation-1',
    );
    final accepted = await repository.acceptProposal('proposal-v2');

    expect(page.valueOrNull?.items, [request]);
    verify(
      () => remote.listMyServiceRequests(
        statuses: {ServiceRequestStatus.open},
        conversationToken: 'conversation-1',
        page: 0,
      ),
    ).called(1);
    expect(
      accepted.errorOrNull,
      const NegotiationConflictFailure(detail: 'O cadastro mudou.'),
    );
  });

  test('the driver repository returns what the datasource read', () async {
    final remote = MockDriverNegotiationRemoteDataSource();
    final repository = DriverNegotiationRepositoryImpl(remote: remote);
    final proposal = ProposalDto.fromJson(proposalJson(dependentName: null));
    when(() => remote.sendProposal(any())).thenAnswer((_) async => proposal);
    when(
      () => remote.declineServiceRequest(any(), reason: any(named: 'reason')),
    ).thenThrow(dioFailure(null));

    final sent = await repository.sendProposal(
      const ProposalDraft(serviceRequestToken: 'request-1'),
    );
    final declined = await repository.declineServiceRequest(
      'request-1',
      reason: 'Sem vaga.',
    );

    expect(sent.valueOrNull, proposal);
    expect(declined.errorOrNull, const NegotiationNetworkFailure());
    verify(() => remote.declineServiceRequest('request-1', reason: 'Sem vaga.'))
        .called(1);
  });
}
