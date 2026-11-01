import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/app.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_detail_page.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

import 'core/ui/localized_harness.dart';
import 'modules/conversations/conversations_mocks.dart';
import 'modules/negotiations/negotiations_fixtures.dart';

void main() {
  testWidgets('opens the chat of the negotiation as the client', (
    tester,
  ) async {
    final openedTokens = <String>[];
    final chat = MockChatCubit();
    whenListen(
      chat,
      const Stream<ChatState>.empty(),
      initialState: const ChatState(status: ChatStatus.ready),
    );
    when(chat.start).thenAnswer((_) async {});
    getIt.registerFactoryParam<ChatCubit, String, void>((conversationToken, _) {
      openedTokens.add(conversationToken);
      return chat;
    });
    final timeline = MockNegotiationTimelineCubit();
    whenListen(
      timeline,
      const Stream<NegotiationTimelineState<ClientServiceRequest>>.empty(),
      initialState: const NegotiationTimelineState<ClientServiceRequest>(
        status: NegotiationTimelineStatus.none,
      ),
    );
    when(timeline.load).thenAnswer((_) async {});
    final timelineTokens = <String>[];
    getIt.registerFactoryParam<
      NegotiationTimelineCubit<ClientServiceRequest>,
      String,
      void
    >((conversationToken, _) {
      timelineTokens.add(conversationToken);
      return timeline;
    });
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      localizedHarness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                openClientNegotiationChat(context, TestClientServiceRequest()),
            child: const Text('Conversar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Conversar'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage<ClientServiceRequest>), findsOneWidget);
    expect(timelineTokens, ['conversation-1']);
    expect(openedTokens, ['conversation-1']);
    expect(find.text('Carlos Souza'), findsOneWidget);
  });

  testWidgets('a request without a conversation opens nothing', (tester) async {
    await tester.pumpWidget(
      localizedHarness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => openClientNegotiationChat(
              context,
              TestClientServiceRequest(conversationToken: null),
            ),
            child: const Text('Conversar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Conversar'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage<ClientServiceRequest>), findsNothing);
  });

  testWidgets('accepting from the chat asks before opening the detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedHarness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => openProposalAcceptance(
              context,
              TestClientServiceRequest(),
              TestProposal(),
            ),
            child: const Text('Aceitar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Aceitar'));
    await tester.pumpAndSettle();

    expect(find.text('Aceitar proposta?'), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Aceitar proposta?'), findsNothing);
    expect(find.byType(ProposalDetailPage), findsNothing);
  });
}
