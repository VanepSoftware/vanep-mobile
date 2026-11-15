import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/presentation/formatters/chat_timeline.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';

import '../conversations_fixtures.dart';

void main() {
  final requestSent = RequestSentEvent(at: DateTime(2026, 10, 11, 18));
  final firstMessage = TestConversationMessage(
    token: 'message-a',
    body: 'Oi',
    sender: ConversationParticipant.client,
    sentAt: DateTime(2026, 10, 11, 18, 5),
  );
  final nextDayMessage = TestConversationMessage(
    token: 'message-b',
    body: 'Bom dia',
    sender: ConversationParticipant.driver,
    sentAt: DateTime(2026, 10, 12, 8),
  );
  final proposalSent = ProposalSentEvent(
    at: DateTime(2026, 10, 12, 9),
    proposalToken: 'proposal-v1',
    version: 1,
    isOpen: true,
  );

  test('mixes messages and events by date with one divider per day', () {
    final timeline = buildChatTimeline(
      messages: [nextDayMessage, firstMessage],
      events: [proposalSent, requestSent],
    );

    expect(timeline, [
      ChatDayEntry(DateTime(2026, 10, 11)),
      ChatEventEntry(requestSent),
      ChatMessageEntry(firstMessage),
      ChatDayEntry(DateTime(2026, 10, 12)),
      ChatMessageEntry(nextDayMessage),
      ChatEventEntry(proposalSent),
    ]);
  });

  test('without a negotiation it has only the messages and the days', () {
    expect(buildChatTimeline(messages: [firstMessage], events: const []), [
      ChatDayEntry(DateTime(2026, 10, 11)),
      ChatMessageEntry(firstMessage),
    ]);
  });
}
