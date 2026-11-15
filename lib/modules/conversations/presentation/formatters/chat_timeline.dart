import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';

sealed class ChatTimelineEntry extends Equatable {
  const ChatTimelineEntry();
}

final class ChatDayEntry extends ChatTimelineEntry {
  const ChatDayEntry(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

final class ChatMessageEntry extends ChatTimelineEntry {
  const ChatMessageEntry(this.message);

  final ConversationMessage message;

  @override
  List<Object?> get props => [message];
}

final class ChatEventEntry extends ChatTimelineEntry {
  const ChatEventEntry(this.event);

  final NegotiationEvent event;

  @override
  List<Object?> get props => [event];
}

DateTime localDayOf(DateTime moment) {
  final local = moment.toLocal();
  return DateTime(local.year, local.month, local.day);
}

DateTime timeOfEntry(ChatTimelineEntry entry) {
  return switch (entry) {
    ChatMessageEntry(:final message) => message.sentAt,
    ChatEventEntry(:final event) => event.at,
    ChatDayEntry(:final day) => day,
  };
}

List<ChatTimelineEntry> buildChatTimeline({
  required List<ConversationMessage> messages,
  required List<NegotiationEvent> events,
}) {
  final entries = <ChatTimelineEntry>[
    for (final event in events) ChatEventEntry(event),
    for (final message in messages) ChatMessageEntry(message),
  ]..sort((first, second) => timeOfEntry(first).compareTo(timeOfEntry(second)));
  final timeline = <ChatTimelineEntry>[];
  DateTime? currentDay;
  for (final entry in entries) {
    final day = localDayOf(timeOfEntry(entry));
    if (day != currentDay) {
      timeline.add(ChatDayEntry(day));
      currentDay = day;
    }
    timeline.add(entry);
  }
  return timeline;
}
