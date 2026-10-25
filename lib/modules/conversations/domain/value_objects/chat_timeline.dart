import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';

sealed class ChatTimelineEntry extends Equatable {
  const ChatTimelineEntry();

  String get key;

  @override
  List<Object?> get props => [key];
}

final class ChatDayDivider extends ChatTimelineEntry {
  const ChatDayDivider(this.day);

  final DateTime day;

  @override
  String get key => 'day-${day.year}-${day.month}-${day.day}';
}

final class ChatMessageEntry extends ChatTimelineEntry {
  const ChatMessageEntry(this.message);

  final ConversationMessage message;

  @override
  String get key => 'message-${message.token}';

  @override
  List<Object?> get props => [key, message.body, message.sentAt];
}

final class ChatNegotiationEntry extends ChatTimelineEntry {
  const ChatNegotiationEntry(this.event, {this.isCurrentProposal = false});

  final NegotiationEvent event;

  final bool isCurrentProposal;

  @override
  String get key => 'negotiation-${event.token}';

  @override
  List<Object?> get props => [key, event, isCurrentProposal];
}

final class ChatPrivacyNotice extends ChatTimelineEntry {
  const ChatPrivacyNotice();

  @override
  String get key => 'privacy-notice';
}

final class ChatAgreementNotice extends ChatTimelineEntry {
  const ChatAgreementNotice();

  @override
  String get key => 'agreement-notice';
}

DateTime localDayOf(DateTime moment) {
  final local = moment.toLocal();
  return DateTime(local.year, local.month, local.day);
}

List<ChatTimelineEntry> entriesForEvent(
  NegotiationEvent event,
  ConversationNegotiation negotiation,
) {
  return switch (event) {
    QuoteRequestEvent() => [
      ChatNegotiationEntry(event),
      const ChatPrivacyNotice(),
    ],
    ProposalVersionEvent() when negotiation.isCurrentProposal(event) => [
      ChatNegotiationEntry(event, isCurrentProposal: true),
      const ChatAgreementNotice(),
    ],
    _ => [ChatNegotiationEntry(event)],
  };
}

List<ChatTimelineEntry> buildChatTimeline({
  required List<ConversationMessage> messages,
  required ConversationNegotiation negotiation,
}) {
  final moments = <(DateTime, List<ChatTimelineEntry>)>[
    for (final event in negotiation.events)
      (event.occurredAt, entriesForEvent(event, negotiation)),
    for (final message in messages)
      (message.sentAt, [ChatMessageEntry(message)]),
  ]..sort((first, second) => first.$1.compareTo(second.$1));

  final timeline = <ChatTimelineEntry>[];
  DateTime? currentDay;
  for (final (moment, entries) in moments) {
    final day = localDayOf(moment);
    if (day != currentDay) {
      timeline.add(ChatDayDivider(day));
      currentDay = day;
    }
    timeline.addAll(entries);
  }
  return timeline;
}
