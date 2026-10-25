import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

enum ClientProposalsStatus { initial, loading, ready, loadFailed }

enum ProposalsTab { open, closed }

class ClientProposalsState extends Equatable {
  const ClientProposalsState({
    this.status = ClientProposalsStatus.initial,
    this.proposals,
    this.failure,
    this.selectedChildToken,
    this.tab = ProposalsTab.open,
  });

  final ClientProposalsStatus status;

  final ClientProposals? proposals;

  final ClientProposalsFailure? failure;

  final String? selectedChildToken;

  final ProposalsTab tab;

  bool get hasLoadFailed => status == ClientProposalsStatus.loadFailed;

  bool get showsSkeleton => proposals == null && !hasLoadFailed;

  ProposalChild? get selectedChild =>
      proposals?.childWithToken(selectedChildToken);

  ProposalsFeed get visibleFeed =>
      proposals?.feedFor(selectedChildToken) ?? const ProposalsFeed();

  ClientProposalsState withTab(ProposalsTab tab) {
    return ClientProposalsState(
      status: status,
      proposals: proposals,
      failure: failure,
      selectedChildToken: selectedChildToken,
      tab: tab,
    );
  }

  ClientProposalsState withSelectedChild(String? childToken) {
    return ClientProposalsState(
      status: status,
      proposals: proposals,
      failure: failure,
      selectedChildToken: childToken,
      tab: tab,
    );
  }

  @override
  List<Object?> get props => [
    status,
    proposals,
    failure,
    selectedChildToken,
    tab,
  ];
}
