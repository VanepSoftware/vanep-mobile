import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_conversation_messages.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/list_my_conversations.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/open_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/send_conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/usecases/watch_conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_realtime_event.dart';

import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

void main() {
  late MockConversationRepository repository;

  setUp(() {
    repository = MockConversationRepository();
  });

  test('OpenConversation opens the conversation with the driver', () async {
    when(() => repository.openConversation('driver-1')).thenAnswer(
      (_) async =>
          const Ok<ConversationFailure, Conversation>(testConversation),
    );

    final result = await OpenConversation(repository)('driver-1');

    expect(result.valueOrNull, testConversation);
  });

  test('OpenConversation forwards a failure', () async {
    when(() => repository.openConversation('driver-1')).thenAnswer(
      (_) async => const Err<ConversationFailure, Conversation>(
        ConversationDriverUnavailableFailure(),
      ),
    );

    final result = await OpenConversation(repository)('driver-1');

    expect(result.errorOrNull, const ConversationDriverUnavailableFailure());
  });

  test('ListMyConversations returns what the repository returns', () async {
    when(repository.listMyConversations).thenAnswer(
      (_) async =>
          const Ok<ConversationFailure, List<Conversation>>([testConversation]),
    );

    final result = await ListMyConversations(repository)();

    expect(result.valueOrNull, [testConversation]);
  });

  test('ListConversationMessages asks for the requested page', () async {
    final page = ConversationMessagePage(
      messages: [testDriverMessage, testClientMessage],
      hasMore: true,
    );
    when(
      () =>
          repository.listMessages(conversationToken: 'conversation-1', page: 2),
    ).thenAnswer(
      (_) async => Ok<ConversationFailure, ConversationMessagePage>(page),
    );

    final result = await ListConversationMessages(repository)(
      conversationToken: 'conversation-1',
      page: 2,
    );

    expect(result.valueOrNull, page);
  });

  group('SendConversationMessage', () {
    test('sends the trimmed text', () async {
      when(
        () => repository.sendMessage(
          conversationToken: 'conversation-1',
          body: 'Tem vaga para a manhã?',
        ),
      ).thenAnswer(
        (_) async =>
            Ok<ConversationFailure, ConversationMessage>(testClientMessage),
      );

      final result = await SendConversationMessage(repository)(
        conversationToken: 'conversation-1',
        body: '  Tem vaga para a manhã?  ',
      );

      expect(result.valueOrNull, testClientMessage);
    });

    test('rejects blank text without calling the repository', () async {
      final result = await SendConversationMessage(repository)(
        conversationToken: 'conversation-1',
        body: '   ',
      );

      expect(result.errorOrNull, const ConversationMessageRejectedFailure());
      verifyZeroInteractions(repository);
    });

    test('accepts text at the length limit', () async {
      final atLimit = 'a' * conversationMessageMaxLength;
      when(
        () => repository.sendMessage(
          conversationToken: 'conversation-1',
          body: atLimit,
        ),
      ).thenAnswer(
        (_) async =>
            Ok<ConversationFailure, ConversationMessage>(testClientMessage),
      );

      final result = await SendConversationMessage(repository)(
        conversationToken: 'conversation-1',
        body: atLimit,
      );

      expect(result.isOk, isTrue);
    });

    test(
      'rejects text over the length limit without calling the repository',
      () async {
        final result = await SendConversationMessage(repository)(
          conversationToken: 'conversation-1',
          body: 'a' * (conversationMessageMaxLength + 1),
        );

        expect(result.errorOrNull, const ConversationMessageRejectedFailure());
        verifyZeroInteractions(repository);
      },
    );
  });

  test('WatchConversation streams the conversation events', () {
    final received = ConversationMessageReceived(testDriverMessage);
    when(() => repository.watchConversation('conversation-1')).thenAnswer(
      (_) => Stream.fromIterable([
        received,
        const ConversationRealtimeReconnected(),
      ]),
    );

    expect(
      WatchConversation(repository)('conversation-1'),
      emitsInOrder([
        received,
        const ConversationRealtimeReconnected(),
        emitsDone,
      ]),
    );
  });

  test('isBlankConversationMessage treats whitespace as blank', () {
    expect(isBlankConversationMessage(' \n\t '), isTrue);
    expect(isBlankConversationMessage(' oi '), isFalse);
  });
}
