import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';

import '../../../core/ui/localized_harness.dart';
import '../conversations_fixtures.dart';
import '../conversations_mocks.dart';

final negotiatingState = ChatState(
  status: ChatStatus.ready,
  conversation: testConversation,
  messages: [
    localMessage(
      'hello',
      ConversationParticipant.driver,
      DateTime(2026, 10, 10, 21, 2),
    ),
  ],
  negotiation: fullNegotiation,
);

void main() {
  late MockChatCubit cubit;
  late List<String> openedProfiles;

  setUp(() {
    cubit = MockChatCubit();
    openedProfiles = [];
  });

  Future<void> pumpChat(
    WidgetTester tester,
    ChatState state, {
    ConversationParticipant viewerSide = ConversationParticipant.client,
  }) async {
    tester.view.physicalSize = const Size(1170, 9000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    whenListen(cubit, const Stream<ChatState>.empty(), initialState: state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<ChatCubit>.value(
          value: cubit,
          child: ChatPage(
            viewerSide: viewerSide,
            onDriverProfileTapped: openedProfiles.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the header shows the driver with the proposal vehicle', (
    tester,
  ) async {
    await pumpChat(tester, negotiatingState);

    expect(find.text('Carlos Motorista'), findsOneWidget);
    expect(find.text('Motorista · Master 2019'), findsOneWidget);

    await tester.tap(find.byTooltip('Ver perfil do motorista'));

    expect(openedProfiles, ['driver-1']);
  });

  testWidgets('the banner shows the current proposal', (tester) async {
    await pumpChat(tester, negotiatingState);

    expect(
      find.textContaining('Proposta v2', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('expira em 21/10', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Ver'));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
  });

  testWidgets('the timeline mixes the negotiation with the messages', (
    tester,
  ) async {
    await pumpChat(tester, negotiatingState);

    expect(find.text('10 de outubro'), findsOneWidget);
    expect(find.text('13 de outubro'), findsOneWidget);
    expect(find.text('Pedido de orçamento'), findsOneWidget);
    expect(find.text('Pedro, 11 · Colégio Delta, tarde'), findsOneWidget);
    expect(find.text('Seg a sex · quarta só ida'), findsOneWidget);
    expect(find.text('Você · 20:14'), findsOneWidget);
    expect(find.text('Mensagem hello'), findsOneWidget);
    expect(find.text('Proposta · versão 1'), findsOneWidget);
    expect(find.text('Substituída'), findsOneWidget);
    expect(find.text('Pedido de ajuste'), findsOneWidget);
    expect(
      find.text('“Tem como melhorar o valor? São 4 voltas por semana.”'),
      findsOneWidget,
    );
    expect(find.text('Proposta · versão 2'), findsOneWidget);
    expect(find.text('Atual'), findsOneWidget);
    expect(find.text('1º fev a 17 dez 2027'), findsOneWidget);
    expect(
      find.text(
        'O motorista vê apenas o bairro e o primeiro nome até o aceite.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Acordos feitos na conversa só valem se incluídos em uma nova '
        'versão da proposta.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the client can answer the current proposal', (tester) async {
    await pumpChat(tester, negotiatingState);

    expect(find.text('Ver proposta'), findsOneWidget);
    expect(find.byTooltip('Pedir ajuste na proposta'), findsOneWidget);

    await tester.tap(find.text('Aceitar'));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
  });

  testWidgets('the adjustment button opens coming soon', (tester) async {
    await pumpChat(tester, negotiatingState);

    await tester.tap(find.byTooltip('Pedir ajuste na proposta'));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
  });

  testWidgets('the driver sees their own proposal without actions', (
    tester,
  ) async {
    await pumpChat(
      tester,
      negotiatingState,
      viewerSide: ConversationParticipant.driver,
    );

    expect(find.text('Ana Cliente'), findsOneWidget);
    expect(find.text('Responsável'), findsOneWidget);
    expect(find.byTooltip('Ver perfil do motorista'), findsNothing);
    expect(find.text('Aceitar'), findsNothing);
    expect(find.text('Ver proposta'), findsNothing);
    expect(find.byTooltip('Pedir ajuste na proposta'), findsNothing);
  });

  testWidgets('without a proposal there is no banner nor adjustment', (
    tester,
  ) async {
    await pumpChat(
      tester,
      negotiatingState.copyWith(negotiation: requestOnlyNegotiation),
    );

    expect(find.text('Pedido de orçamento'), findsOneWidget);
    expect(find.text('Motorista'), findsOneWidget);
    expect(find.text('Ver'), findsNothing);
    expect(find.byTooltip('Pedir ajuste na proposta'), findsNothing);
  });

  testWidgets('without negotiation the chat shows only the messages', (
    tester,
  ) async {
    await pumpChat(
      tester,
      negotiatingState.copyWith(negotiation: ConversationNegotiation.none),
    );

    expect(find.text('Mensagem hello'), findsOneWidget);
    expect(find.text('Pedido de orçamento'), findsNothing);
    expect(
      find.text(
        'O motorista vê apenas o bairro e o primeiro nome até o aceite.',
      ),
      findsNothing,
    );
  });
}
