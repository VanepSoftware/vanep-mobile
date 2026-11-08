import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation_message.dart';
import 'package:vanep_mobile/modules/conversations/domain/value_objects/conversation_negotiation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../conversations_mocks.dart';

void main() {
  late MockChatCubit chat;
  late MockDriverNegotiationTimelineCubit timeline;
  late List<String> calls;

  final today = DateTime(2026, 10, 4, 10);
  final versionWithAdjustment = TestProposal(
    createdAt: DateTime(2026, 10, 2, 9),
    adjustments: [
      TestProposalAdjustment(
        createdAt: DateTime(2026, 10, 3, 10),
        note: 'Consegue um pouco menos?',
      ),
    ],
  );

  ConversationNegotiation<DriverServiceRequest> negotiationOf({
    required bool hasPendingAdjustment,
  }) {
    return ConversationNegotiation<DriverServiceRequest>(
      request: TestDriverServiceRequest(
        status: ServiceRequestStatus.answered,
        currentProposal: TestProposalSummary(
          hasPendingAdjustment: hasPendingAdjustment,
        ),
        createdAt: DateTime(2026, 10, 1, 18),
      ),
      versions: [versionWithAdjustment],
    );
  }

  setUp(() {
    chat = MockChatCubit();
    timeline = MockDriverNegotiationTimelineCubit();
    calls = [];
    whenListen(
      chat,
      const Stream<ChatState>.empty(),
      initialState: const ChatState(status: ChatStatus.ready),
    );
    when(timeline.load).thenAnswer((_) async {});
  });

  Future<void> pumpChat(
    WidgetTester tester,
    ConversationNegotiation<DriverServiceRequest> negotiation,
  ) async {
    tester.view.physicalSize = const Size(430, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      timeline,
      const Stream<NegotiationTimelineState<DriverServiceRequest>>.empty(),
      initialState: NegotiationTimelineState<DriverServiceRequest>(
        status: NegotiationTimelineStatus.ready,
        negotiation: negotiation,
      ),
    );
    await tester.pumpWidget(
      localizedHarness(
        MultiBlocProvider(
          providers: [
            BlocProvider<ChatCubit>.value(value: chat),
            BlocProvider<NegotiationTimelineCubit<DriverServiceRequest>>.value(
              value: timeline,
            ),
          ],
          child: ChatPage<DriverServiceRequest>(
            counterpartName: 'Maria',
            viewerSide: ConversationParticipant.driver,
            clock: () => today,
            negotiationActions: NegotiationChatActions(
              onSeeProposal: (request) async => calls.add('see'),
              onNewVersion: (request, proposal) async =>
                  calls.add('new version ${proposal.version}'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the request card shows the first name and the notice', (
    tester,
  ) async {
    await pumpChat(tester, negotiationOf(hasPendingAdjustment: false));

    expect(find.text('Theo, 9 anos'), findsOneWidget);
    expect(find.text('Embarque em Taguatinga'), findsOneWidget);
    expect(
      find.text('Endereço e nome completo disponíveis após o aceite.'),
      findsOneWidget,
    );
  });

  testWidgets('a pending adjustment shows the banner with respond', (
    tester,
  ) async {
    await pumpChat(tester, negotiationOf(hasPendingAdjustment: true));

    expect(find.text('Ajuste solicitado'), findsOneWidget);

    await tester.tap(find.text('Responder'));
    await tester.pumpAndSettle();

    expect(calls, ['new version 1']);
    verify(timeline.load).called(1);
  });

  testWidgets('the adjustment card answers with a new version', (tester) async {
    await pumpChat(tester, negotiationOf(hasPendingAdjustment: true));

    await tester.tap(find.text('Nova versão'));
    await tester.pumpAndSettle();

    expect(calls, ['new version 1']);
  });

  testWidgets('the driver cannot accept nor ask for an adjustment', (
    tester,
  ) async {
    await pumpChat(tester, negotiationOf(hasPendingAdjustment: true));

    expect(find.text('Aceitar'), findsNothing);
    expect(find.text('Ver proposta'), findsNothing);
    expect(find.byTooltip('Pedir ajuste'), findsNothing);
    expect(find.textContaining('Manter'), findsNothing);
  });

  testWidgets('without a pending adjustment the banner opens the proposal', (
    tester,
  ) async {
    await pumpChat(tester, negotiationOf(hasPendingAdjustment: false));

    expect(find.text('Nova versão'), findsNothing);

    await tester.tap(find.text('Ver'));
    await tester.pumpAndSettle();

    expect(calls, ['see']);
  });
}
