import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';

bool isShownInConversation(NegotiationEvent event) {
  return event is RequestSentEvent ||
      event is ProposalSentEvent ||
      event is AdjustmentRequestedEvent;
}

class ConversationNegotiation<R extends ServiceRequest> extends Equatable {
  ConversationNegotiation({required this.request, required this.versions})
    : events = buildNegotiationHistory(
        request,
        versions,
      ).where(isShownInConversation).toList();

  final R request;

  final List<Proposal> versions;

  final List<NegotiationEvent> events;

  Proposal? get openProposal {
    for (final proposal in versions.reversed) {
      if (proposal.status == ProposalStatus.sent) return proposal;
    }
    return null;
  }

  Proposal? versionWithToken(String proposalToken) {
    for (final proposal in versions) {
      if (proposal.token == proposalToken) return proposal;
    }
    return null;
  }

  @override
  List<Object?> get props => [request, versions];
}
