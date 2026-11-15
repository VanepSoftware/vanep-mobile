import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_turn.dart';

// Each account may keep at most this many negotiations open at once
// (proposals to answer plus requests waiting for a driver); the back enforces it.
const openRequestsLimit = 5;

bool reachesOpenRequestsLimit(int openCount) => openCount >= openRequestsLimit;

bool isRequestForChild(ServiceRequest request, String childToken) {
  return request.items.any((item) => item.dependentToken == childToken);
}

List<ClientServiceRequest> requestsForChild(
  List<ClientServiceRequest> requests,
  String childToken,
) {
  return requests
      .where((request) => isRequestForChild(request, childToken))
      .toList();
}

class ProposalsFeed extends Equatable {
  const ProposalsFeed({
    this.open = const [],
    this.closed = const [],
    this.closedCount = 0,
  });

  final List<ClientServiceRequest> open;

  final List<ClientServiceRequest> closed;

  final int closedCount;

  List<ClientServiceRequest> get pending =>
      open.where((request) => clientTurnOf(request).isClientsTurn).toList();

  List<ClientServiceRequest> get awaiting => open
      .where((request) => clientTurnOf(request).isWaitingForDriver)
      .toList();

  int get openCount => open.length;

  ProposalsFeed forChild(String? childToken) {
    if (childToken == null) return this;
    final closedOfChild = requestsForChild(closed, childToken);
    return ProposalsFeed(
      open: requestsForChild(open, childToken),
      closed: closedOfChild,
      closedCount: closedOfChild.length,
    );
  }

  @override
  List<Object?> get props => [open, closed, closedCount];
}

class ClientProposals extends Equatable {
  const ClientProposals({
    required this.loadedAt,
    required this.children,
    required this.feed,
    this.closedPage = 0,
    this.hasMoreClosed = false,
  });

  final DateTime loadedAt;

  final List<Dependent> children;

  final ProposalsFeed feed;

  final int closedPage;

  final bool hasMoreClosed;

  bool get canFilterByChild => children.length > 1;

  int get openRequestsCount => feed.openCount;

  bool get hasReachedOpenRequestsLimit =>
      reachesOpenRequestsLimit(openRequestsCount);

  ProposalsFeed feedFor(String? childToken) => feed.forChild(childToken);

  Dependent? childWithToken(String? childToken) {
    for (final child in children) {
      if (child.token == childToken) return child;
    }
    return null;
  }

  ClientProposals withClosedPage(
    NegotiationPage<ClientServiceRequest> nextPage, {
    required int page,
  }) {
    final loadedTokens = {for (final request in feed.closed) request.token};
    return ClientProposals(
      loadedAt: loadedAt,
      children: children,
      feed: ProposalsFeed(
        open: feed.open,
        closed: [
          ...feed.closed,
          for (final request in nextPage.items)
            if (!loadedTokens.contains(request.token)) request,
        ],
        closedCount: nextPage.totalElements,
      ),
      closedPage: page,
      hasMoreClosed: !nextPage.isLast,
    );
  }

  ClientProposals withRequestClosed(ClientServiceRequest closedRequest) {
    return ClientProposals(
      loadedAt: loadedAt,
      children: children,
      feed: ProposalsFeed(
        open: [
          for (final request in feed.open)
            if (request.token != closedRequest.token) request,
        ],
        closed: [closedRequest, ...feed.closed],
        closedCount: feed.closedCount + 1,
      ),
      closedPage: closedPage,
      hasMoreClosed: hasMoreClosed,
    );
  }

  @override
  List<Object?> get props => [
    loadedAt,
    children,
    feed,
    closedPage,
    hasMoreClosed,
  ];
}
