import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/conversations_inbox_tab.dart';

import '../../../core/ui/localized_harness.dart';
import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

Widget harness(
  ConversationsInboxCubit cubit,
  Future<void> Function(Conversation) onConversationTapped, {
  ConversationParticipant viewerSide = ConversationParticipant.driver,
}) {
  return localizedHarness(
    Scaffold(
      body: BlocProvider<ConversationsInboxCubit>.value(
        value: cubit,
        child: ConversationsInboxTab(
          viewerSide: viewerSide,
          onConversationTapped: onConversationTapped,
        ),
      ),
    ),
  );
}

void main() {
  late MockConversationsInboxCubit cubit;

  setUp(() {
    cubit = MockConversationsInboxCubit();
    when(() => cubit.loadConversations()).thenAnswer((_) async {});
  });

  void seed(ConversationsInboxState state) {
    whenListen(
      cubit,
      const Stream<ConversationsInboxState>.empty(),
      initialState: state,
    );
  }

  testWidgets('lists who wrote and reopens the chat on tap', (tester) async {
    seed(
      const ConversationsInboxState(
        status: ConversationsInboxStatus.ready,
        conversations: [testConversation],
      ),
    );
    final opened = <Conversation>[];

    await tester.pumpWidget(
      harness(cubit, (conversation) async => opened.add(conversation)),
    );
    await tester.tap(find.text('Ana Cliente'));
    await tester.pump();

    expect(find.text('Mensagens'), findsOneWidget);
    expect(opened, [testConversation]);
    verify(() => cubit.loadConversations()).called(1);
  });

  testWidgets('no conversations says where they will appear', (tester) async {
    seed(const ConversationsInboxState(status: ConversationsInboxStatus.ready));

    await tester.pumpWidget(harness(cubit, (_) async {}));

    expect(
      find.text(
        'Nenhuma conversa ainda. Quando um cliente escrever, ela aparece aqui.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a failure is explained and can be retried', (tester) async {
    seed(
      const ConversationsInboxState(
        status: ConversationsInboxStatus.loadFailed,
        failure: ConversationNetworkFailure(),
      ),
    );

    await tester.pumpWidget(harness(cubit, (_) async {}));
    await tester.tap(find.text('Tentar novamente'));

    expect(
      find.text('Sem conexão com o servidor. Tente novamente.'),
      findsOneWidget,
    );
    verify(() => cubit.loadConversations()).called(1);
  });

  testWidgets('the client sees each conversation by driver name', (
    tester,
  ) async {
    seed(
      const ConversationsInboxState(
        status: ConversationsInboxStatus.ready,
        conversations: [testConversation],
      ),
    );

    await tester.pumpWidget(
      harness(cubit, (_) async {}, viewerSide: ConversationParticipant.client),
    );

    expect(find.text('Carlos Motorista'), findsOneWidget);
    expect(find.text('Ana Cliente'), findsNothing);
  });

  testWidgets('an empty list tells the client how to start a conversation', (
    tester,
  ) async {
    seed(const ConversationsInboxState(status: ConversationsInboxStatus.ready));

    await tester.pumpWidget(
      harness(cubit, (_) async {}, viewerSide: ConversationParticipant.client),
    );

    expect(
      find.text(
        'Nenhuma conversa ainda. Para falar com um motorista, abra o perfil dele em Vans e toque em “Conversar com o motorista”.',
      ),
      findsOneWidget,
    );
  });
}
