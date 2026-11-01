import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';

class ProposalAdjustmentState extends Equatable {
  const ProposalAdjustmentState({
    this.draft = const ProposalAdjustmentDraft(),
    this.isSending = false,
    this.failure,
    this.sentProposal,
  });

  final ProposalAdjustmentDraft draft;

  final bool isSending;

  final NegotiationFailure? failure;

  final Proposal? sentProposal;

  bool get canSend =>
      !isSending && validateProposalAdjustmentDraft(draft).isEmpty;

  ProposalAdjustmentState copyWith({
    ProposalAdjustmentDraft? draft,
    bool? isSending,
    NegotiationFailure? failure,
    Proposal? sentProposal,
  }) {
    return ProposalAdjustmentState(
      draft: draft ?? this.draft,
      isSending: isSending ?? false,
      failure: failure,
      sentProposal: sentProposal,
    );
  }

  @override
  List<Object?> get props => [draft, isSending, failure, sentProposal];
}
