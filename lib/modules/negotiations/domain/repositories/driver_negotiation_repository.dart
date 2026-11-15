import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

abstract class DriverNegotiationRepository {
  Future<Result<NegotiationFailure, NegotiationPage<DriverServiceRequest>>>
  listMyServiceRequests({
    required Set<ServiceRequestStatus> statuses,
    String? conversationToken,
    int page = 0,
  });

  Future<Result<NegotiationFailure, DriverServiceRequest>> findServiceRequest(
    String token,
  );

  Future<Result<NegotiationFailure, DriverServiceRequest>>
  declineServiceRequest(String token, {String? reason});

  Future<Result<NegotiationFailure, Proposal>> sendProposal(
    ProposalDraft draft,
  );

  Future<Result<NegotiationFailure, List<Proposal>>> listProposalVersions(
    String serviceRequestToken,
  );

  Future<Result<NegotiationFailure, Proposal>> findProposal(String token);

  Future<Result<NegotiationFailure, Proposal>> withdrawProposal(String token);
}
