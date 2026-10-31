import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

abstract class ClientNegotiationRepository {
  Future<Result<NegotiationFailure, ClientServiceRequest>> sendServiceRequest(
    ServiceRequestDraft draft,
  );

  Future<Result<NegotiationFailure, NegotiationPage<ClientServiceRequest>>>
  listMyServiceRequests({
    required Set<ServiceRequestStatus> statuses,
    String? conversationToken,
    int page = 0,
  });

  Future<Result<NegotiationFailure, ClientServiceRequest>> findServiceRequest(
    String token,
  );

  Future<Result<NegotiationFailure, ClientServiceRequest>>
  withdrawServiceRequest(String token);

  Future<Result<NegotiationFailure, List<Proposal>>> listProposalVersions(
    String serviceRequestToken,
  );

  Future<Result<NegotiationFailure, Proposal>> findProposal(String token);

  Future<Result<NegotiationFailure, Proposal>> acceptProposal(String token);

  Future<Result<NegotiationFailure, Proposal>> declineProposal(
    String token, {
    String? reason,
  });

  Future<Result<NegotiationFailure, Proposal>> requestProposalAdjustment(
    String token,
    ProposalAdjustmentDraft draft,
  );
}
