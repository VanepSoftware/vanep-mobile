import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_composer_setup.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';

NegotiationFailure negotiationFailureFromVans(DriverVanFailure failure) {
  return failure == DriverVanFailure.network
      ? const NegotiationNetworkFailure()
      : const NegotiationUnexpectedFailure();
}

class LoadProposalComposer {
  const LoadProposalComposer({
    required this.findServiceRequest,
    required this.findProposal,
    required this.listMyVans,
  });

  final FindDriverServiceRequest findServiceRequest;

  final FindDriverProposal findProposal;

  final ListMyVans listMyVans;

  Future<Result<NegotiationFailure, ProposalComposerSetup>> call(
    String requestToken, {
    String? previousProposalToken,
  }) async {
    final (requestResult, proposalResult, vansResult) = await (
      findServiceRequest(requestToken),
      findPreviousVersion(previousProposalToken),
      listMyVans(),
    ).wait;
    final vansFailure = vansResult.errorOrNull;
    final failure =
        requestResult.errorOrNull ??
        proposalResult.errorOrNull ??
        (vansFailure == null ? null : negotiationFailureFromVans(vansFailure));
    if (failure != null) return Err(failure);
    return Ok(
      ProposalComposerSetup.from(
        request: requestResult.valueOrNull!,
        vans: vansResult.valueOrNull!,
        previousVersion: proposalResult.valueOrNull,
      ),
    );
  }

  Future<Result<NegotiationFailure, Proposal?>> findPreviousVersion(
    String? proposalToken,
  ) async {
    if (proposalToken == null) return const Ok(null);
    return findProposal(proposalToken);
  }
}
