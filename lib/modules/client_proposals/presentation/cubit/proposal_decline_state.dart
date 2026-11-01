import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_decline_reason.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

enum ProposalDeclineOutcome { declined, outdated }

class ProposalDeclineState extends Equatable {
  const ProposalDeclineState({
    this.reason,
    this.message = '',
    this.isSending = false,
    this.failure,
    this.declinedProposal,
  });

  final ProposalDeclineReason? reason;

  final String message;

  final bool isSending;

  final NegotiationFailure? failure;

  final Proposal? declinedProposal;

  bool get canSend => reason != null && !isSending;

  ProposalDeclineState copyWith({
    ProposalDeclineReason? reason,
    String? message,
    bool? isSending,
    NegotiationFailure? failure,
    Proposal? declinedProposal,
  }) {
    return ProposalDeclineState(
      reason: reason ?? this.reason,
      message: message ?? this.message,
      isSending: isSending ?? false,
      failure: failure,
      declinedProposal: declinedProposal,
    );
  }

  @override
  List<Object?> get props => [
    reason,
    message,
    isSending,
    failure,
    declinedProposal,
  ];
}
