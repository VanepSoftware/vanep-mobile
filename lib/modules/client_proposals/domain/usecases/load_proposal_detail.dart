import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_detail.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_client_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_proposal_versions.dart';

class LoadProposalDetail {
  const LoadProposalDetail({
    required this.findProposal,
    required this.findServiceRequest,
    required this.listVersions,
  });

  final FindClientProposal findProposal;

  final FindClientServiceRequest findServiceRequest;

  final ListClientProposalVersions listVersions;

  Future<Result<NegotiationFailure, ProposalDetail>> call(
    String requestToken, {
    String? proposalToken,
  }) async {
    if (proposalToken == null) {
      final result = await findServiceRequest(requestToken);
      return result.fold(
        Err.new,
        (request) => Ok(ProposalDetail(request: request)),
      );
    }
    final (proposalResult, requestResult, versionsResult) = await (
      findProposal(proposalToken),
      findServiceRequest(requestToken),
      listVersions(requestToken),
    ).wait;
    final failure =
        proposalResult.errorOrNull ??
        requestResult.errorOrNull ??
        versionsResult.errorOrNull;
    if (failure != null) return Err(failure);
    return Ok(
      ProposalDetail(
        request: requestResult.valueOrNull!,
        proposal: proposalResult.valueOrNull,
        versions: versionsResult.valueOrNull!,
      ),
    );
  }
}
