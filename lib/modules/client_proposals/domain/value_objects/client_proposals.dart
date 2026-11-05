import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposal.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_child.dart';

// Each account may keep at most this many proposals and requests open at once
// (proposals to answer plus requests waiting for a driver).
const openRequestsLimit = 5;

List<T> entriesOfChild<T extends ChildProposalEntry>(
  List<T> entries,
  String? childToken,
) {
  if (childToken == null) return entries;
  return entries.where((entry) => entry.childToken == childToken).toList();
}

class ProposalsFeed extends Equatable {
  const ProposalsFeed({
    this.pending = const [],
    this.awaiting = const [],
    this.closed = const [],
  });

  final List<PendingProposal> pending;

  final List<SentRequest> awaiting;

  final List<ClosedProposal> closed;

  int get openCount => pending.length + awaiting.length;

  int get closedCount => closed.length;

  ProposalsFeed forChild(String? childToken) {
    if (childToken == null) return this;
    return ProposalsFeed(
      pending: entriesOfChild(pending, childToken),
      awaiting: entriesOfChild(awaiting, childToken),
      closed: entriesOfChild(closed, childToken),
    );
  }

  @override
  List<Object?> get props => [pending, awaiting, closed];
}

class ClientProposals extends Equatable {
  const ClientProposals({
    required this.loadedAt,
    required this.children,
    required this.feed,
  });

  final DateTime loadedAt;

  final List<ProposalChild> children;

  final ProposalsFeed feed;

  bool get canFilterByChild => children.length > 1;

  int get openRequestsCount => feed.openCount;

  bool get hasReachedOpenRequestsLimit =>
      openRequestsCount >= openRequestsLimit;

  ProposalsFeed feedFor(String? childToken) => feed.forChild(childToken);

  ProposalChild? childWithToken(String? childToken) {
    for (final child in children) {
      if (child.token == childToken) return child;
    }
    return null;
  }

  @override
  List<Object?> get props => [loadedAt, children, feed];
}
