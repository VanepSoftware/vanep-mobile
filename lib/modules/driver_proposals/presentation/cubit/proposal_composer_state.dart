import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_composer_setup.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/installment_preview.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';

enum ProposalComposerStatus { initial, loading, ready, loadFailed }

enum ProposalComposerOutcome { sent, outdated }

const missingValueErrors = {
  ProposalDraftError.totalAmountRequired,
  ProposalDraftError.periodRequired,
  ProposalDraftError.timeRequired,
  ProposalDraftError.vehicleRequired,
};

class ProposalComposerState extends Equatable {
  const ProposalComposerState({
    required this.today,
    this.status = ProposalComposerStatus.initial,
    this.setup,
    this.isSending = false,
    this.failure,
    this.sentProposal,
  });

  final DateTime today;

  final ProposalComposerStatus status;

  final ProposalComposerSetup? setup;

  final bool isSending;

  final NegotiationFailure? failure;

  final Proposal? sentProposal;

  ProposalDraft? get draft => setup?.draft;

  bool get isReady => status == ProposalComposerStatus.ready && setup != null;

  Set<ProposalDraftError> get errors {
    final draft = this.draft;
    if (draft == null) return const {};
    return validateProposalDraft(draft, today: today);
  }

  Set<ProposalDraftError> get visibleErrors {
    final draft = this.draft;
    return {
      for (final error in errors)
        if (!missingValueErrors.contains(error) &&
            !(error == ProposalDraftError.installmentsOutOfRange &&
                draft?.installments == null) &&
            !(error == ProposalDraftError.dueDayOutOfRange &&
                draft?.dueDay == null))
          error,
    };
  }

  bool get canSend => isReady && !isSending && errors.isEmpty;

  int? get previewInstallmentCents {
    final total = draft?.totalAmountCents;
    final installments = draft?.installments;
    if (total == null ||
        total <= 0 ||
        installments == null ||
        installments < 1 ||
        installments > proposalMaxInstallments) {
      return null;
    }
    return previewInstallmentAmount(total, installments);
  }

  ProposalComposerState copyWith({
    ProposalComposerStatus? status,
    ProposalComposerSetup? setup,
    bool? isSending,
    NegotiationFailure? failure,
    Proposal? sentProposal,
  }) {
    return ProposalComposerState(
      today: today,
      status: status ?? this.status,
      setup: setup ?? this.setup,
      isSending: isSending ?? false,
      failure: failure,
      sentProposal: sentProposal,
    );
  }

  @override
  List<Object?> get props => [
    today,
    status,
    setup,
    isSending,
    failure,
    sentProposal,
  ];
}
