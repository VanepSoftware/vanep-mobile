import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

enum ClientProposalsStatus { initial, loading, ready, loadFailed }

enum ProposalsTab { open, closed }

class ClientProposalsState extends Equatable {
  const ClientProposalsState({
    this.status = ClientProposalsStatus.initial,
    this.proposals,
    this.failure,
    this.selectedChildToken,
    this.tab = ProposalsTab.open,
    this.isLoadingMoreClosed = false,
    this.cancellingRequestToken,
    this.actionFailure,
  });

  final ClientProposalsStatus status;

  final ClientProposals? proposals;

  final ClientProposalsFailure? failure;

  final String? selectedChildToken;

  final ProposalsTab tab;

  final bool isLoadingMoreClosed;

  final String? cancellingRequestToken;

  final NegotiationFailure? actionFailure;

  bool get hasLoadFailed => status == ClientProposalsStatus.loadFailed;

  bool get showsSkeleton => proposals == null && !hasLoadFailed;

  Dependent? get selectedChild => proposals?.childWithToken(selectedChildToken);

  ProposalsFeed get visibleFeed =>
      proposals?.feedFor(selectedChildToken) ?? const ProposalsFeed();

  ClientProposalsState copyWith({
    ClientProposals? proposals,
    String? selectedChildToken,
    bool clearSelectedChild = false,
    ProposalsTab? tab,
    bool? isLoadingMoreClosed,
    String? cancellingRequestToken,
    bool clearCancellingRequest = false,
    NegotiationFailure? actionFailure,
  }) {
    return ClientProposalsState(
      status: status,
      proposals: proposals ?? this.proposals,
      failure: failure,
      selectedChildToken: clearSelectedChild
          ? null
          : (selectedChildToken ?? this.selectedChildToken),
      tab: tab ?? this.tab,
      isLoadingMoreClosed: isLoadingMoreClosed ?? this.isLoadingMoreClosed,
      cancellingRequestToken: clearCancellingRequest
          ? null
          : (cancellingRequestToken ?? this.cancellingRequestToken),
      actionFailure: actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    proposals,
    failure,
    selectedChildToken,
    tab,
    isLoadingMoreClosed,
    cancellingRequestToken,
    actionFailure,
  ];
}
