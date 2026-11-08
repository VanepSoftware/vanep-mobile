import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_driver_proposal.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/usecases/load_proposal_composer.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

import '../../driver_vans/driver_vans_mocks.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  late MockFindDriverProposal findProposal;
  late MockFindDriverServiceRequest findRequest;
  late MockListDriverProposalVersions listVersions;
  late MockListMyVans listMyVans;

  setUp(() {
    findProposal = MockFindDriverProposal();
    findRequest = MockFindDriverServiceRequest();
    listVersions = MockListDriverProposalVersions();
    listMyVans = MockListMyVans();
    when(() => findRequest('request-adjust'))
        .thenAnswer((_) async => Ok(adjustmentRequest));
    when(() => findProposal('proposal-v1'))
        .thenAnswer((_) async => Ok(versionWithAdjustment));
    when(() => listVersions('request-adjust'))
        .thenAnswer((_) async => Ok([versionWithAdjustment]));
    when(() => listMyVans()).thenAnswer((_) async => const Ok([masterVan]));
  });

  group('LoadDriverProposal', () {
    LoadDriverProposal useCase() => LoadDriverProposal(
      findProposal: findProposal,
      findServiceRequest: findRequest,
      listVersions: listVersions,
    );

    test('reads the proposal, the request and the versions', () async {
      final result = await useCase()(
        'request-adjust',
        proposalToken: 'proposal-v1',
      );

      final detail = result.valueOrNull!;
      expect(detail.request, adjustmentRequest);
      expect(detail.proposal, versionWithAdjustment);
      expect(detail.versions, [versionWithAdjustment]);
    });

    test('any failure fails the load', () async {
      when(() => listVersions('request-adjust'))
          .thenAnswer((_) async => const Err(NegotiationNetworkFailure()));

      final result = await useCase()(
        'request-adjust',
        proposalToken: 'proposal-v1',
      );

      expect(result.errorOrNull, const NegotiationNetworkFailure());
    });
  });

  group('LoadProposalComposer', () {
    LoadProposalComposer useCase() => LoadProposalComposer(
      findServiceRequest: findRequest,
      findProposal: findProposal,
      listMyVans: listMyVans,
    );

    test('a first proposal reads only the request and the vans', () async {
      final result = await useCase()('request-adjust');

      expect(result.valueOrNull!.vans, [masterVan]);
      verifyNever(() => findProposal(any()));
    });

    test('a new version also reads the previous one', () async {
      final result = await useCase()(
        'request-adjust',
        previousProposalToken: 'proposal-v1',
      );

      expect(result.valueOrNull!.draft.totalAmountCents, 408000);
    });

    test('a failure reading the vans fails the load', () async {
      when(() => listMyVans())
          .thenAnswer((_) async => const Err(DriverVanFailure.network));

      final result = await useCase()('request-adjust');

      expect(result.errorOrNull, const NegotiationNetworkFailure());
    });

    test('an unexpected vans failure is unexpected', () {
      expect(
        negotiationFailureFromVans(DriverVanFailure.invalidData),
        const NegotiationUnexpectedFailure(),
      );
    });
  });
}
