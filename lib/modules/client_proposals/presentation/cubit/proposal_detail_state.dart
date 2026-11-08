import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';

enum ProposalDetailStatus { initial, loading, ready, loadFailed, notFound }

class ProposalDetailState extends Equatable {
  const ProposalDetailState({
    this.status = ProposalDetailStatus.initial,
    this.proposalToken,
    this.request,
    this.proposal,
    this.versions = const [],
    this.loadFailure,
    this.isAccepting = false,
    this.actionFailure,
    this.acceptedProposal,
    this.isCancelling = false,
    this.cancelledRequest,
  });

  final ProposalDetailStatus status;

  final String? proposalToken;

  final ClientServiceRequest? request;

  final Proposal? proposal;

  final List<Proposal> versions;

  final NegotiationFailure? loadFailure;

  final bool isAccepting;

  final NegotiationFailure? actionFailure;

  final Proposal? acceptedProposal;

  final bool isCancelling;

  final ClientServiceRequest? cancelledRequest;

  bool get isRequestMode => proposalToken == null;

  bool get isReady => status == ProposalDetailStatus.ready && request != null;

  bool get canAct => proposal?.status == ProposalStatus.sent;

  Proposal? get previousVersion {
    final version = proposal?.version;
    if (version == null) return null;
    for (final candidate in versions) {
      if (candidate.version == version - 1) return candidate;
    }
    return null;
  }

  String? get currentVersionToken {
    final currentToken = request?.currentProposal?.token;
    final proposal = this.proposal;
    if (proposal == null || proposal.status != ProposalStatus.superseded) {
      return null;
    }
    return currentToken == proposal.token ? null : currentToken;
  }

  List<NegotiationEvent> get history {
    final request = this.request;
    if (request == null) return const [];
    return buildNegotiationHistory(request, versions);
  }

  ProposalDetailState copyWith({
    ProposalDetailStatus? status,
    String? proposalToken,
    ClientServiceRequest? request,
    Proposal? proposal,
    List<Proposal>? versions,
    bool? isAccepting,
    NegotiationFailure? actionFailure,
    Proposal? acceptedProposal,
    bool? isCancelling,
    ClientServiceRequest? cancelledRequest,
  }) {
    return ProposalDetailState(
      status: status ?? this.status,
      proposalToken: proposalToken ?? this.proposalToken,
      request: request ?? this.request,
      proposal: proposal ?? this.proposal,
      versions: versions ?? this.versions,
      loadFailure: loadFailure,
      isAccepting: isAccepting ?? false,
      actionFailure: actionFailure,
      acceptedProposal: acceptedProposal,
      isCancelling: isCancelling ?? false,
      cancelledRequest: cancelledRequest,
    );
  }

  @override
  List<Object?> get props => [
    status,
    proposalToken,
    request,
    proposal,
    versions,
    loadFailure,
    isAccepting,
    actionFailure,
    acceptedProposal,
    isCancelling,
    cancelledRequest,
  ];
}
