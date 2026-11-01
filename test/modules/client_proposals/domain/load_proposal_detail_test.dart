import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_proposal_detail.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_detail.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockFindClientProposal findProposal;
  late MockFindClientServiceRequest findServiceRequest;
  late MockListClientProposalVersions listVersions;
  late LoadProposalDetail loadProposalDetail;

  final requestToken = testProposalForSiblings.token;

  setUp(() {
    findProposal = MockFindClientProposal();
    findServiceRequest = MockFindClientServiceRequest();
    listVersions = MockListClientProposalVersions();
    loadProposalDetail = LoadProposalDetail(
      findProposal: findProposal,
      findServiceRequest: findServiceRequest,
      listVersions: listVersions,
    );
    when(() => findServiceRequest(requestToken))
        .thenAnswer((_) async => Ok(testProposalForSiblings));
    when(() => findProposal(testVersion2.token))
        .thenAnswer((_) async => Ok(testVersion2));
    when(() => listVersions(requestToken))
        .thenAnswer((_) async => Ok([testVersion1, testVersion2]));
  });

  test('reads the proposal, the request and the versions', () async {
    final result = await loadProposalDetail(
      requestToken,
      proposalToken: testVersion2.token,
    );

    expect(
      result.valueOrNull,
      ProposalDetail(
        request: testProposalForSiblings,
        proposal: testVersion2,
        versions: [testVersion1, testVersion2],
      ),
    );
  });

  test('a request without a proposal reads only the request', () async {
    final result = await loadProposalDetail(requestToken);

    expect(
      result.valueOrNull,
      ProposalDetail(request: testProposalForSiblings),
    );
    verifyNever(() => findProposal(any()));
    verifyNever(() => listVersions(any()));
  });

  test('any of the three failing fails the detail', () async {
    when(() => listVersions(requestToken))
        .thenAnswer((_) async => const Err(NegotiationNotFoundFailure()));

    final result = await loadProposalDetail(
      requestToken,
      proposalToken: testVersion2.token,
    );

    expect(result.errorOrNull, const NegotiationNotFoundFailure());
  });
}
