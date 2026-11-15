import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_proposal_detail.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/find_driver_service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_driver_proposal_versions.dart';

class LoadDriverProposal {
  const LoadDriverProposal({
    required this.findProposal,
    required this.findServiceRequest,
    required this.listVersions,
  });

  final FindDriverProposal findProposal;

  final FindDriverServiceRequest findServiceRequest;

  final ListDriverProposalVersions listVersions;

  Future<Result<NegotiationFailure, DriverProposalDetail>> call(
    String requestToken, {
    required String proposalToken,
  }) async {
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
      DriverProposalDetail(
        request: requestResult.valueOrNull!,
        proposal: proposalResult.valueOrNull!,
        versions: versionsResult.valueOrNull!,
      ),
    );
  }
}
