import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/negotiation_highlights.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/usecases/list_client_service_requests.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

const expiredRequestWindow = Duration(days: 7);

List<String> childNamesOf(List<ClientServiceRequest> requests) {
  return {
    for (final request in requests)
      for (final item in request.items) item.dependentName,
  }.toList();
}

class FindNegotiationHighlights {
  const FindNegotiationHighlights({
    required this.listServiceRequests,
    this.clock = DateTime.now,
  });

  final ListClientServiceRequests listServiceRequests;

  final DateTime Function() clock;

  Future<NegotiationHighlights> call() async {
    final (openResult, expiredResult) = await (
      listServiceRequests(statuses: openServiceRequestStatuses),
      listServiceRequests(statuses: {ServiceRequestStatus.expired}),
    ).wait;
    final open = openResult.valueOrNull?.items;
    final expired = expiredResult.valueOrNull?.items;
    if (open == null || expired == null) return NegotiationHighlights.none;

    final expiredSince = clock().subtract(expiredRequestWindow);
    return NegotiationHighlights(
      newProposals: [
        for (final request in open)
          if (clientTurnOf(request) == ClientTurn.proposalReceived)
            NewProposalItem(request: request),
      ],
      expiredRequests: [
        for (final request in expired)
          if (request.updatedAt.isAfter(expiredSince))
            ExpiredRequestItem(driverName: request.driverName),
      ],
      openCount: open.length,
      childNames: childNamesOf(open),
    );
  }
}
