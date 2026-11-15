import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';

import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

final olderMessage = TestConversationMessage(
  token: 'message-0',
  body: 'Bom dia',
  sender: ConversationParticipant.client,
  sentAt: DateTime.utc(2026, 10, 12, 8),
);

final liveMessage = TestConversationMessage(
  token: 'message-3',
  body: 'Combinado',
  sender: ConversationParticipant.driver,
  sentAt: DateTime.utc(2026, 10, 12, 9, 10),
);

Ok<ConversationFailure, ConversationMessagePage> pageOf(
  List<ConversationMessage> messages, {
  bool hasMore = false,
}) => Ok(ConversationMessagePage(messages: messages, hasMore: hasMore));

void main() {
  late MockListConversationMessages listMessages;
  late MockSendConversationMessage sendMessage;
  late MockWatchConversation watchConversation;
  late StreamController<ConversationRealtimeEvent> realtime;
  late bool realtimeCancelled;

  ChatCubit chatOf() => ChatCubit(
    listConversationMessages: listMessages,
    sendConversationMessage: sendMessage,
    watchConversation: watchConversation,
    conversationToken: testConversation.token,
  );

  void stubPage(
    int page,
    Result<ConversationFailure, ConversationMessagePage> result,
  ) {
    when(() => listMessages(conversationToken: 'conversation-1', page: page))
        .thenAnswer((_) async => result);
  }

  setUp(() {
    listMessages = MockListConversationMessages();
    sendMessage = MockSendConversationMessage();
    watchConversation = MockWatchConversation();
    realtimeCancelled = false;
    realtime = StreamController<ConversationRealtimeEvent>(
      onCancel: () => realtimeCancelled = true,
    );
    when(() => watchConversation('conversation-1'))
        .thenAnswer((_) => realtime.stream);
    stubPage(0, pageOf([testDriverMessage, testClientMessage], hasMore: true));
  });

  tearDown(() => realtime.close());

  test('loads the conversation it was given, oldest first', () async {
    final cubit = chatOf();

    await cubit.start();

    expect(cubit.state.status, ChatStatus.ready);
    expect(cubit.state.messages, [testClientMessage, testDriverMessage]);
    expect(cubit.state.hasMore, isTrue);
    await cubit.close();
  });

  test('a failure to load can be retried', () async {
    stubPage(0, const Err(ConversationNotFoundFailure()));
    final cubit = chatOf();

    await cubit.start();

    expect(cubit.state.status, ChatStatus.loadFailed);
    expect(cubit.state.failure, const ConversationNotFoundFailure());

    stubPage(0, pageOf([testDriverMessage]));
    await cubit.start();

    expect(cubit.state.status, ChatStatus.ready);
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test('older messages are loaded above the current ones', () async {
    stubPage(1, pageOf([olderMessage]));
    final cubit = chatOf();
    await cubit.start();

    await cubit.loadOlderMessages();

    expect(cubit.state.messages.first, olderMessage);
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.nextPage, 2);

    await cubit.loadOlderMessages();

    verify(() => listMessages(conversationToken: 'conversation-1', page: 1))
        .called(1);
    await cubit.close();
  });

  test('a sent message is added and the send reports success', () async {
    when(
      () => sendMessage(conversationToken: 'conversation-1', body: 'Combinado'),
    ).thenAnswer(
      (_) async => Ok<ConversationFailure, ConversationMessage>(liveMessage),
    );
    final cubit = chatOf();
    await cubit.start();

    final sent = await cubit.sendMessage('Combinado');

    expect(sent, isTrue);
    expect(cubit.state.messages.last, liveMessage);
    expect(cubit.state.isSending, isFalse);
    await cubit.close();
  });

  test(
    'a failed send keeps the conversation and reports the failure',
    () async {
      when(() => sendMessage(conversationToken: 'conversation-1', body: 'Oi'))
          .thenAnswer(
            (_) async => const Err<ConversationFailure, ConversationMessage>(
              ConversationNetworkFailure(),
            ),
          );
      final cubit = chatOf();
      await cubit.start();

      final sent = await cubit.sendMessage('Oi');

      expect(sent, isFalse);
      expect(cubit.state.failure, const ConversationNetworkFailure());
      expect(cubit.state.messages, hasLength(2));
      await cubit.close();
    },
  );

  test('a live message is added once, even when it arrives twice', () async {
    final cubit = chatOf();
    await cubit.start();

    realtime
      ..add(ConversationMessageReceived(liveMessage))
      ..add(ConversationMessageReceived(liveMessage));
    await pumpEventQueue();

    expect(cubit.state.messages, [
      testClientMessage,
      testDriverMessage,
      liveMessage,
    ]);
    await cubit.close();
  });

  test(
    'reconnecting reloads the latest page to recover missed messages',
    () async {
      final cubit = chatOf();
      await cubit.start();
      stubPage(0, pageOf([liveMessage, testDriverMessage], hasMore: true));

      realtime.add(const ConversationRealtimeReconnected());
      await pumpEventQueue();

      expect(cubit.state.messages, [
        testClientMessage,
        testDriverMessage,
        liveMessage,
      ]);
      await cubit.close();
    },
  );

  test('closing stops listening to the conversation', () async {
    final cubit = chatOf();
    await cubit.start();

    await cubit.close();

    expect(realtimeCancelled, isTrue);
  });
}
