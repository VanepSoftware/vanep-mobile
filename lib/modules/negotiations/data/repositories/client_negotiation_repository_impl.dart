import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/client_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/negotiation_call_guard.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/client_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class ClientNegotiationRepositoryImpl implements ClientNegotiationRepository {
  const ClientNegotiationRepositoryImpl({required this.remote});

  final ClientNegotiationRemoteDataSource remote;

  @override
  Future<Result<NegotiationFailure, ClientServiceRequest>> sendServiceRequest(
    ServiceRequestDraft draft,
  ) {
    return guardNegotiationCall(() => remote.sendServiceRequest(draft));
  }

  @override
  Future<Result<NegotiationFailure, NegotiationPage<ClientServiceRequest>>>
  listMyServiceRequests({
    required Set<ServiceRequestStatus> statuses,
    String? conversationToken,
    int page = 0,
  }) {
    return guardNegotiationCall(
      () => remote.listMyServiceRequests(
        statuses: statuses,
        conversationToken: conversationToken,
        page: page,
      ),
    );
  }

  @override
  Future<Result<NegotiationFailure, ClientServiceRequest>> findServiceRequest(
    String token,
  ) {
    return guardNegotiationCall(() => remote.findServiceRequest(token));
  }

  @override
  Future<Result<NegotiationFailure, ClientServiceRequest>>
  withdrawServiceRequest(String token) {
    return guardNegotiationCall(() => remote.withdrawServiceRequest(token));
  }

  @override
  Future<Result<NegotiationFailure, List<Proposal>>> listProposalVersions(
    String serviceRequestToken,
  ) {
    return guardNegotiationCall(
      () => remote.listProposalVersions(serviceRequestToken),
    );
  }

  @override
  Future<Result<NegotiationFailure, Proposal>> findProposal(String token) {
    return guardNegotiationCall(() => remote.findProposal(token));
  }

  @override
  Future<Result<NegotiationFailure, Proposal>> acceptProposal(String token) {
    return guardNegotiationCall(() => remote.acceptProposal(token));
  }

  @override
  Future<Result<NegotiationFailure, Proposal>> declineProposal(
    String token, {
    String? reason,
  }) {
    return guardNegotiationCall(
      () => remote.declineProposal(token, reason: reason),
    );
  }

  @override
  Future<Result<NegotiationFailure, Proposal>> requestProposalAdjustment(
    String token,
    ProposalAdjustmentDraft draft,
  ) {
    return guardNegotiationCall(
      () => remote.requestProposalAdjustment(token, draft),
    );
  }
}
