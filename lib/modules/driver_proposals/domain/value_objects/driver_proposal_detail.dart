import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';

class DriverProposalDetail extends Equatable {
  const DriverProposalDetail({
    required this.request,
    required this.proposal,
    this.versions = const [],
  });

  final DriverServiceRequest request;

  final Proposal proposal;

  final List<Proposal> versions;

  bool get isOpen => proposal.status == ProposalStatus.sent;

  ProposalAdjustment? get pendingAdjustment {
    if (!isOpen || driverTurnOf(request) != DriverTurn.adjustmentRequested) {
      return null;
    }
    return proposal.adjustments.lastOrNull;
  }

  List<NegotiationEvent> get history =>
      buildNegotiationHistory(request, versions);

  @override
  List<Object?> get props => [request, proposal, versions];
}
