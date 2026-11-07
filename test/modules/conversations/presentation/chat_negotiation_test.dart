import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/conversation_message_bubble.dart';
import 'package:vanep_mobile/modules/conversations/presentation/widgets/negotiation_chat_cards.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

const nbsp = ' ';

void main() {
  late MockChatCubit chat;
  late MockNegotiationTimelineCubit timeline;
  late List<String> calls;

  final today = DateTime(2026, 10, 25, 10);
  final request = TestClientServiceRequest(
    status: ServiceRequestStatus.answered,
    desiredStartDate: DateTime(2027, 2, 1),
    createdAt: DateTime(2026, 10, 20, 18),
    items: [
      TestClientRequestItem(
        dependentName: 'Ana Souza',
        dependentBirthDate: '2018-06-01',
        days: [
          for (final weekday in [
            Weekday.monday,
            Weekday.tuesday,
            Weekday.thursday,
            Weekday.friday,
          ])
            TestRequestedDay(weekday: weekday),
          const TestRequestedDay(
            weekday: Weekday.wednesday,
            schoolShift: SchoolShift.afternoon,
            needsReturn: false,
          ),
        ],
      ),
    ],
  );
  final version1 = TestProposal(
    status: ProposalStatus.superseded,
    installmentAmountCents: 34000,
    createdAt: DateTime(2026, 10, 21, 9),
    adjustments: [
      TestProposalAdjustment(
        createdAt: DateTime(2026, 10, 22, 10),
        note: 'Consegue um pouco menos?',
      ),
    ],
  );
  final version2 = TestProposal(
    token: 'proposal-v2',
    version: 2,
    installmentAmountCents: 30000,
    validUntil: DateTime(2026, 10, 31, 12),
    createdAt: DateTime(2026, 10, 23, 9),
  );
  final negotiation = ConversationNegotiation<ClientServiceRequest>(
    request: request,
    versions: [version1, version2],
  );

  setUp(() {
    chat = MockChatCubit();
    timeline = MockNegotiationTimelineCubit();
    calls = [];
    whenListen(
      chat,
      const Stream<ChatState>.empty(),
      initialState: ChatState(
        status: ChatStatus.ready,
        messages: [
          TestConversationMessage(
            token: 'message-hello',
            body: 'Oi, tudo bem?',
            sender: ConversationParticipant.client,
            sentAt: DateTime(2026, 10, 20, 18, 5),
          ),
        ],
      ),
    );
    when(timeline.load).thenAnswer((_) async {});
  });

  Future<void> pumpChat(
    WidgetTester tester,
    NegotiationTimelineState<ClientServiceRequest> state,
  ) async {
    tester.view.physicalSize = const Size(430, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      timeline,
      const Stream<NegotiationTimelineState<ClientServiceRequest>>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      localizedHarness(
        MultiBlocProvider(
          providers: [
            BlocProvider<ChatCubit>.value(value: chat),
            BlocProvider<NegotiationTimelineCubit<ClientServiceRequest>>.value(
              value: timeline,
            ),
          ],
          child: ChatPage<ClientServiceRequest>(
            counterpartName: 'Carlos Souza',
            viewerSide: ConversationParticipant.client,
            clock: () => today,
            negotiationActions: NegotiationChatActions(
              onSeeProposal: (request) async => calls.add('see'),
              onAccept: (request, proposal) async =>
                  calls.add('accept ${proposal.version}'),
              onAskAdjustment: (request, proposal) async =>
                  calls.add('adjust ${proposal.version}'),
            ),
          ),
        ),
      ),
    );
  }

  final ready = NegotiationTimelineState<ClientServiceRequest>(
    status: NegotiationTimelineStatus.ready,
    negotiation: negotiation,
  );

  testWidgets('the banner shows the open version and opens it', (tester) async {
    await pumpChat(tester, ready);

    expect(
      find.text('Proposta v2 · R\$${nbsp}300/mês · 12x · expira em 31/10'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ver'));
    await tester.pump();

    expect(calls, ['see']);
    verify(timeline.load).called(1);
  });

  testWidgets('the request card shows the children, days and neighborhood', (
    tester,
  ) async {
    await pumpChat(tester, ready);

    final card = find.byType(NegotiationRequestCard);
    Finder inCard(String text) =>
        find.descendant(of: card, matching: find.text(text));
    expect(inCard('Ana Souza, 8 anos'), findsOneWidget);
    expect(inCard('Colégio Delta, tarde'), findsOneWidget);
    expect(inCard('Seg, Ter, Qui, Sex · ida e volta'), findsOneWidget);
    expect(inCard('Qua · só ida'), findsOneWidget);
    expect(inCard('Início em 1 fev 2027'), findsOneWidget);
    expect(inCard('Embarque em Taguatinga'), findsOneWidget);
    expect(find.textContaining('QNL'), findsNothing);
    expect(find.textContaining('o motorista vê'), findsNothing);
  });

  testWidgets('each card has a header with its icon and title', (tester) async {
    await pumpChat(tester, ready);

    Finder header(Type card, IconData icon, String title) => find.descendant(
      of: find.byType(card),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is NegotiationChatCard &&
            widget.icon == icon &&
            widget.title == title,
      ),
    );
    expect(
      header(
        NegotiationRequestCard,
        Icons.send_outlined,
        'Pedido de orçamento',
      ),
      findsOneWidget,
    );
    expect(
      header(
        NegotiationVersionCard,
        Icons.request_quote_outlined,
        'Proposta · versão 2',
      ),
      findsOneWidget,
    );
    expect(
      header(NegotiationAdjustmentCard, Icons.tune, 'Pedido de ajuste'),
      findsOneWidget,
    );
  });

  testWidgets(
    'the client cards sit on the right and the driver ones on the left',
    (tester) async {
      await pumpChat(tester, ready);

      Alignment alignmentOf(Finder card) =>
          tester
                  .widget<Align>(
                    find
                        .descendant(of: card, matching: find.byType(Align))
                        .first,
                  )
                  .alignment
              as Alignment;
      expect(
        alignmentOf(find.byType(NegotiationRequestCard)),
        Alignment.centerRight,
      );
      expect(
        alignmentOf(find.byType(NegotiationAdjustmentCard)),
        Alignment.centerRight,
      );
      expect(
        alignmentOf(find.byType(NegotiationVersionCard).first),
        Alignment.centerLeft,
      );
    },
  );

  testWidgets('the versions show replaced and current, with the actions', (
    tester,
  ) async {
    await pumpChat(tester, ready);

    expect(find.byType(NegotiationVersionCard), findsNWidgets(2));
    expect(find.text('Substituída'), findsOneWidget);
    expect(find.text('Atual'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Versão atual')), findsOneWidget);
    expect(
      find.text('R\$${nbsp}340/mês · 12x', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('R\$${nbsp}4.080'), findsNWidgets(2));
    expect(find.textContaining('no total'), findsNothing);
    expect(find.text('Vence dia 10'), findsNWidgets(2));
    expect(find.text('1 fev a 17 dez 2027'), findsOneWidget);
    expect(find.text('Expira em 31/10'), findsOneWidget);
    expect(
      find.text(
        'Acordos feitos na conversa só valem se incluídos em uma nova versão da proposta.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Ver proposta'));
    await tester.tap(find.text('Aceitar'));
    await tester.pump();

    expect(calls, ['see', 'accept 2']);
  });

  testWidgets('the adjustment card shows the subject and the note', (
    tester,
  ) async {
    await pumpChat(tester, ready);

    expect(find.byType(NegotiationAdjustmentCard), findsOneWidget);
    expect(find.text('Valor: R\$ 290'), findsOneWidget);
    expect(find.text('Consegue um pouco menos?'), findsOneWidget);
  });

  testWidgets('the adjustment button next to the input asks for a change', (
    tester,
  ) async {
    await pumpChat(tester, ready);

    await tester.tap(find.byTooltip('Pedir ajuste'));
    await tester.pump();

    expect(calls, ['adjust 2']);
  });

  testWidgets('a conversation without a negotiation shows only the messages', (
    tester,
  ) async {
    await pumpChat(
      tester,
      const NegotiationTimelineState(status: NegotiationTimelineStatus.none),
    );

    expect(find.text('Oi, tudo bem?'), findsOneWidget);
    expect(find.byType(NegotiationRequestCard), findsNothing);
    expect(find.byType(NegotiationVersionCard), findsNothing);
    expect(find.text('Ver'), findsNothing);
    expect(find.byTooltip('Pedir ajuste'), findsNothing);
  });

  testWidgets('a negotiation that failed to load offers to try again', (
    tester,
  ) async {
    await pumpChat(
      tester,
      const NegotiationTimelineState(
        status: NegotiationTimelineStatus.loadFailed,
      ),
    );

    expect(find.text('Oi, tudo bem?'), findsOneWidget);
    expect(
      find.text('Não foi possível carregar a negociação.'),
      findsOneWidget,
    );
    expect(find.byType(NegotiationRequestCard), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    verify(timeline.load).called(1);
  });

  testWidgets('a long conversation mounts only what is on screen', (
    tester,
  ) async {
    whenListen(
      chat,
      const Stream<ChatState>.empty(),
      initialState: ChatState(
        status: ChatStatus.ready,
        messages: [
          for (var index = 0; index < 300; index++)
            TestConversationMessage(
              token: 'message-$index',
              body: 'Mensagem $index',
              sender: ConversationParticipant.client,
              sentAt: DateTime(2026, 10, 28, 8).add(Duration(minutes: index)),
            ),
        ],
      ),
    );

    await pumpChat(tester, ready);

    expect(find.text('Mensagem 299'), findsOneWidget);
    expect(find.text('Mensagem 0'), findsNothing);
    expect(
      tester.widgetList(find.byType(ConversationMessageBubble)).length,
      lessThan(150),
    );
  });
}
