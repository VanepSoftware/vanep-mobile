import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';

import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

const otherConversation = TestConversation(
  token: 'conversation-2',
  clientName: 'Bruno Cliente',
);

void main() {
  late MockListMyConversations listMyConversations;

  setUp(() {
    listMyConversations = MockListMyConversations();
  });

  void stubList(Result<ConversationFailure, List<Conversation>> result) {
    when(listMyConversations.call).thenAnswer((_) async => result);
  }

  test('loads the conversations in the order the API returns', () async {
    stubList(const Ok([otherConversation, testConversation]));
    final cubit = ConversationsInboxCubit(
      listMyConversations: listMyConversations,
    );

    await cubit.loadConversations();

    expect(cubit.state.status, ConversationsInboxStatus.ready);
    expect(cubit.state.conversations, [otherConversation, testConversation]);
    await cubit.close();
  });

  test('no conversations is an empty state', () async {
    stubList(const Ok([]));
    final cubit = ConversationsInboxCubit(
      listMyConversations: listMyConversations,
    );

    await cubit.loadConversations();

    expect(cubit.state.isEmpty, isTrue);
    await cubit.close();
  });

  test('a failure can be retried', () async {
    stubList(const Err(ConversationNetworkFailure()));
    final cubit = ConversationsInboxCubit(
      listMyConversations: listMyConversations,
    );

    await cubit.loadConversations();

    expect(cubit.state.hasLoadFailed, isTrue);
    expect(cubit.state.failure, const ConversationNetworkFailure());

    stubList(const Ok([testConversation]));
    await cubit.loadConversations();

    expect(cubit.state.status, ConversationsInboxStatus.ready);
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test('reloading keeps the list visible instead of a spinner', () async {
    stubList(const Ok([testConversation]));
    final cubit = ConversationsInboxCubit(
      listMyConversations: listMyConversations,
    );
    await cubit.loadConversations();
    final states = <ConversationsInboxState>[];
    final subscription = cubit.stream.listen(states.add);

    stubList(const Ok([otherConversation, testConversation]));
    await cubit.loadConversations();
    await pumpEventQueue();

    expect(states.map((state) => state.status), [
      ConversationsInboxStatus.ready,
    ]);
    expect(cubit.state.conversations.first, otherConversation);
    await subscription.cancel();
    await cubit.close();
  });
}
