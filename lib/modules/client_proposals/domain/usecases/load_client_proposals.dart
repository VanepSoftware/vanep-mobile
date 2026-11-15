import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/usecases/find_my_dependents.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

ClientProposalsFailure clientProposalsFailureFrom(Object failure) {
  return switch (failure) {
    final ClientProposalsFailure failure => failure,
    NegotiationNetworkFailure() ||
    DependentNetworkFailure() ||
    NetworkDriverFailure() ||
    ContractReadinessFailure.network => ClientProposalsFailure.network,
    _ => ClientProposalsFailure.unexpected,
  };
}

class LoadClientProposals {
  const LoadClientProposals({
    required this.listServiceRequests,
    required this.findMyDependents,
    this.clock = DateTime.now,
  });

  final ListClientServiceRequests listServiceRequests;

  final FindMyDependents findMyDependents;

  final DateTime Function() clock;

  Future<Result<ClientProposalsFailure, ClientProposals>> call() async {
    final (openResult, closedResult, childrenResult) = await (
      listServiceRequests(statuses: openServiceRequestStatuses),
      listServiceRequests(statuses: closedServiceRequestStatuses),
      findMyDependents(),
    ).wait;

    final failure =
        openResult.errorOrNull ??
        closedResult.errorOrNull ??
        childrenResult.errorOrNull;
    if (failure != null) return Err(clientProposalsFailureFrom(failure));

    final closedPage = closedResult.valueOrNull!;
    return Ok(
      ClientProposals(
        loadedAt: clock(),
        children: childrenResult.valueOrNull!,
        feed: ProposalsFeed(
          open: openResult.valueOrNull!.items,
          closed: closedPage.items,
          closedCount: closedPage.totalElements,
        ),
        hasMoreClosed: !closedPage.isLast,
      ),
    );
  }
}
