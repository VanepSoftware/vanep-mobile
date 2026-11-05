import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';

class TestConversation implements Conversation {
  const TestConversation({
    this.token = 'conversation-1',
    this.driverToken = 'driver-1',
    this.driverName = 'Carlos Motorista',
    this.clientName = 'Ana Cliente',
    this.lastMessageAt,
  });

  @override
  final String token;

  @override
  final String driverToken;

  @override
  final String driverName;

  @override
  final String clientName;

  @override
  final DateTime? lastMessageAt;
}

class TestConversationMessage implements ConversationMessage {
  const TestConversationMessage({
    required this.token,
    required this.body,
    required this.sender,
    required this.sentAt,
  });

  @override
  final String token;

  @override
  final String body;

  @override
  final ConversationParticipant sender;

  @override
  final DateTime sentAt;
}

const testConversation = TestConversation();

final testClientMessage = TestConversationMessage(
  token: 'message-1',
  body: 'Tem vaga para a manhã?',
  sender: ConversationParticipant.client,
  sentAt: DateTime.utc(2026, 10, 12, 9),
);

final testDriverMessage = TestConversationMessage(
  token: 'message-2',
  body: 'Tenho sim, saio às 6h30.',
  sender: ConversationParticipant.driver,
  sentAt: DateTime.utc(2026, 10, 12, 9, 5),
);
