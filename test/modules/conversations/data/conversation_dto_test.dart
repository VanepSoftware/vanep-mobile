import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/conversations/data/dtos/conversation_dto.dart';
import 'package:vanep_mobile/modules/conversations/data/dtos/conversation_message_dto.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';

void main() {
  test('a conversation without messages has no lastMessageAt', () {
    final conversation = ConversationDto.fromJson(const {
      'token': 'conversation-1',
      'driverToken': 'driver-1',
      'driverName': 'Carlos',
      'clientName': 'Maria',
      'lastMessageAt': null,
    });

    expect(conversation.token, 'conversation-1');
    expect(conversation.driverName, 'Carlos');
    expect(conversation.clientName, 'Maria');
    expect(conversation.lastMessageAt, isNull);
  });

  test('a message maps the API sender and the ISO send time', () {
    final message = ConversationMessageDto.fromJson(const {
      'token': 'message-1',
      'body': 'Tem vaga?',
      'sender': 'DRIVER',
      'sentAt': '2026-10-12T22:22:59.123456Z',
    });

    expect(message.sender, ConversationParticipant.driver);
    expect(message.sentAt, DateTime.utc(2026, 10, 12, 22, 22, 59, 123, 456));
  });

  test('an unknown sender is a format error', () {
    expect(
      () => ConversationMessageDto.fromJson(const {
        'token': 'message-1',
        'body': 'Oi',
        'sender': 'ADMIN',
        'sentAt': '2026-10-12T22:22:59Z',
      }),
      throwsFormatException,
    );
  });

  test('a page has more when it is not the last one', () {
    final page = readConversationMessagePage(const {
      'content': [
        {
          'token': 'message-2',
          'body': 'Tenho',
          'sender': 'DRIVER',
          'sentAt': '2026-10-12T09:05:00Z',
        },
      ],
      'number': 0,
      'totalPages': 2,
    });

    expect(page.messages.single.token, 'message-2');
    expect(page.hasMore, isTrue);
  });

  test('the last page has no more', () {
    final page = readConversationMessagePage(const {
      'content': <Object?>[],
      'number': 1,
      'totalPages': 2,
    });

    expect(page.messages, isEmpty);
    expect(page.hasMore, isFalse);
  });
}
