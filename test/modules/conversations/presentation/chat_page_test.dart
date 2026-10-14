import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/failures/conversation_failure.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_message_bubble.dart';

import '../../../core/ui/localized_harness.dart';
import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

Widget harness(ChatCubit cubit, ConversationParticipant viewerSide) {
  return localizedHarness(
    BlocProvider<ChatCubit>.value(
      value: cubit,
      child: ChatPage(viewerSide: viewerSide),
    ),
  );
}

final readyState = ChatState(
  status: ChatStatus.ready,
  conversation: testConversation,
  messages: [testClientMessage, testDriverMessage],
);

void main() {
  late MockChatCubit cubit;

  setUp(() {
    cubit = MockChatCubit();
  });

  void seed(ChatState state) {
    whenListen(cubit, const Stream<ChatState>.empty(), initialState: state);
  }

  Alignment alignmentOf(WidgetTester tester, String body) {
    final bubble = find.ancestor(
      of: find.text(body),
      matching: find.byType(ConversationMessageBubble),
    );
    final align = tester.widget<Align>(
      find.descendant(of: bubble, matching: find.byType(Align)).first,
    );
    return align.alignment as Alignment;
  }

  testWidgets('the client sees their messages on their side', (tester) async {
    seed(readyState);

    await tester.pumpWidget(harness(cubit, ConversationParticipant.client));

    expect(find.text('Carlos Motorista'), findsOneWidget);
    expect(alignmentOf(tester, testClientMessage.body), Alignment.centerRight);
    expect(alignmentOf(tester, testDriverMessage.body), Alignment.centerLeft);
  });

  testWidgets('the driver sees the same conversation mirrored', (tester) async {
    seed(readyState);

    await tester.pumpWidget(harness(cubit, ConversationParticipant.driver));

    expect(find.text('Ana Cliente'), findsOneWidget);
    expect(alignmentOf(tester, testClientMessage.body), Alignment.centerLeft);
    expect(alignmentOf(tester, testDriverMessage.body), Alignment.centerRight);
  });

  testWidgets('send is disabled while the input is blank', (tester) async {
    seed(readyState);

    await tester.pumpWidget(harness(cubit, ConversationParticipant.client));
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    final send = tester.widget<IconButton>(find.byType(IconButton));
    expect(send.onPressed, isNull);
  });

  testWidgets('a sent message clears the input', (tester) async {
    seed(readyState);
    when(() => cubit.sendMessage('Oi')).thenAnswer((_) async => true);

    await tester.pumpWidget(harness(cubit, ConversationParticipant.client));
    await tester.enterText(find.byType(TextField), 'Oi');
    await tester.pump();
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    verify(() => cubit.sendMessage('Oi')).called(1);
    expect(find.widgetWithText(TextField, 'Oi'), findsNothing);
  });

  testWidgets('a failed send keeps the typed text', (tester) async {
    seed(readyState);
    when(() => cubit.sendMessage('Oi')).thenAnswer((_) async => false);

    await tester.pumpWidget(harness(cubit, ConversationParticipant.client));
    await tester.enterText(find.byType(TextField), 'Oi');
    await tester.pump();
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Oi'), findsOneWidget);
  });

  testWidgets('an empty conversation invites the first message', (
    tester,
  ) async {
    seed(
      const ChatState(status: ChatStatus.ready, conversation: testConversation),
    );

    await tester.pumpWidget(harness(cubit, ConversationParticipant.client));

    expect(find.text('Nenhuma mensagem ainda. Diga olá!'), findsOneWidget);
  });

  testWidgets('a failure to open is explained and can be retried', (
    tester,
  ) async {
    seed(
      const ChatState(
        status: ChatStatus.loadFailed,
        failure: ConversationDriverUnavailableFailure(),
      ),
    );
    when(() => cubit.start()).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit, ConversationParticipant.client));
    await tester.tap(find.text('Tentar novamente'));

    expect(
      find.text('Este motorista não está mais disponível.'),
      findsOneWidget,
    );
    verify(() => cubit.start()).called(1);
  });
}
