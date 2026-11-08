import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';

class NegotiationHighlights extends Equatable {
  const NegotiationHighlights({
    this.newProposals = const [],
    this.expiredRequests = const [],
    this.openCount = 0,
    this.childNames = const [],
  });

  static const none = NegotiationHighlights();

  final List<NewProposalItem> newProposals;

  final List<ExpiredRequestItem> expiredRequests;

  final int openCount;

  final List<String> childNames;

  List<NeedsYouItem> get needsYouItems => [...newProposals, ...expiredRequests];

  @override
  List<Object?> get props => [
    newProposals,
    expiredRequests,
    openCount,
    childNames,
  ];
}
