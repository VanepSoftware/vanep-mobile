import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';

sealed class NegotiationEvent extends Equatable {
  const NegotiationEvent({
    required this.token,
    required this.author,
    required this.occurredAt,
  });

  final String token;

  final ConversationParticipant author;

  final DateTime occurredAt;

  @override
  List<Object?> get props => [token, author, occurredAt];
}

final class QuoteRequestEvent extends NegotiationEvent {
  const QuoteRequestEvent({
    required super.token,
    required super.author,
    required super.occurredAt,
    required this.childName,
    required this.schoolName,
    required this.shift,
    required this.weekdays,
    required this.startsOn,
    required this.boardingPlace,
    this.childAge,
    this.oneWayWeekdays = const [],
  });

  final String childName;

  final int? childAge;

  final String schoolName;

  final SchoolShift shift;

  final List<int> weekdays;

  final List<int> oneWayWeekdays;

  final DateTime startsOn;

  final String boardingPlace;

  @override
  List<Object?> get props => [
    ...super.props,
    childName,
    childAge,
    schoolName,
    shift,
    weekdays,
    oneWayWeekdays,
    startsOn,
    boardingPlace,
  ];
}

final class ProposalVersionEvent extends NegotiationEvent {
  const ProposalVersionEvent({
    required super.token,
    required super.author,
    required super.occurredAt,
    required this.version,
    required this.monthlyFeeCents,
    required this.installments,
    required this.dueDay,
    required this.startsOn,
    required this.endsOn,
    required this.expiresAt,
    required this.vehicleModel,
    required this.vehicleYear,
  });

  final int version;

  final int monthlyFeeCents;

  final int installments;

  final int dueDay;

  final DateTime startsOn;

  final DateTime endsOn;

  final DateTime expiresAt;

  final String vehicleModel;

  final int vehicleYear;

  @override
  List<Object?> get props => [
    ...super.props,
    version,
    monthlyFeeCents,
    installments,
    dueDay,
    startsOn,
    endsOn,
    expiresAt,
    vehicleModel,
    vehicleYear,
  ];
}

final class AdjustmentRequestEvent extends NegotiationEvent {
  const AdjustmentRequestEvent({
    required super.token,
    required super.author,
    required super.occurredAt,
    required this.suggestedMonthlyFeeCents,
    required this.note,
  });

  final int suggestedMonthlyFeeCents;

  final String note;

  @override
  List<Object?> get props => [...super.props, suggestedMonthlyFeeCents, note];
}

class ConversationNegotiation extends Equatable {
  const ConversationNegotiation({this.events = const []});

  static const none = ConversationNegotiation();

  final List<NegotiationEvent> events;

  bool get isEmpty => events.isEmpty;

  ProposalVersionEvent? get currentProposal {
    ProposalVersionEvent? latest;
    for (final proposal in events.whereType<ProposalVersionEvent>()) {
      if (latest == null || proposal.version > latest.version) {
        latest = proposal;
      }
    }
    return latest;
  }

  bool isCurrentProposal(ProposalVersionEvent proposal) =>
      currentProposal?.token == proposal.token;

  bool canAnswerCurrentProposal(ConversationParticipant viewerSide) {
    final proposal = currentProposal;
    return proposal != null && proposal.author != viewerSide;
  }

  @override
  List<Object?> get props => [events];
}
