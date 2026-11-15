import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/negotiations/data/datasources/driver_negotiation_remote_datasource.dart';
import 'package:vanep_mobile/modules/negotiations/data/repositories/negotiation_call_guard.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/repositories/driver_negotiation_repository.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

class DriverNegotiationRepositoryImpl implements DriverNegotiationRepository {
  const DriverNegotiationRepositoryImpl({required this.remote});

  final DriverNegotiationRemoteDataSource remote;

  @override
  Future<Result<NegotiationFailure, NegotiationPage<DriverServiceRequest>>>
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
  Future<Result<NegotiationFailure, DriverServiceRequest>> findServiceRequest(
    String token,
  ) {
    return guardNegotiationCall(() => remote.findServiceRequest(token));
  }

  @override
  Future<Result<NegotiationFailure, DriverServiceRequest>>
  declineServiceRequest(String token, {String? reason}) {
    return guardNegotiationCall(
      () => remote.declineServiceRequest(token, reason: reason),
    );
  }

  @override
  Future<Result<NegotiationFailure, Proposal>> sendProposal(
    ProposalDraft draft,
  ) {
    return guardNegotiationCall(() => remote.sendProposal(draft));
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
  Future<Result<NegotiationFailure, Proposal>> withdrawProposal(String token) {
    return guardNegotiationCall(() => remote.withdrawProposal(token));
  }
}
