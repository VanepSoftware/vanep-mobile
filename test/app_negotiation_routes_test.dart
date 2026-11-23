import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/app.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_detail_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/quote_request_page.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/chat_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_cubit.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/negotiation_timeline_state.dart';
import 'package:vanep_mobile/modules/conversations/presentation/pages/chat_page.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/driver_profile_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

import 'core/ui/localized_harness.dart';
import 'modules/auth/auth_fixtures.dart';
import 'modules/auth/presentation/auth_presentation_mocks.dart';
import 'modules/client_proposals/client_proposals_mocks.dart';
import 'modules/conversations/conversations_mocks.dart';
import 'modules/drivers/drivers_fixtures.dart';
import 'modules/drivers/presentation/drivers_presentation_mocks.dart';
import 'modules/negotiations/negotiations_fixtures.dart';

Widget negotiationRouteHarness(UserType userType, Widget child) {
  final auth = MockAuthCubit();
  whenListen(
    auth,
    const Stream<AuthState>.empty(),
    initialState: AuthAuthenticated(
      FakeAuthSession(profile: FakeUserProfile(type: userType)),
    ),
  );
  return BlocProvider<AuthCubit>(
    create: (_) => auth,
    child: localizedHarness(child),
  );
}

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
      negotiationRouteHarness(
        UserType.client,
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

    expect(tester.takeException(), isNull);
    expect(find.byType(ChatPage<ClientServiceRequest>), findsOneWidget);
    expect(timelineTokens, ['conversation-1']);
    expect(openedTokens, ['conversation-1']);
    expect(find.text('Carlos Souza'), findsOneWidget);
  });

  testWidgets('opens the chat of the negotiation as the driver', (
    tester,
  ) async {
    final chat = MockChatCubit();
    whenListen(
      chat,
      const Stream<ChatState>.empty(),
      initialState: const ChatState(status: ChatStatus.ready),
    );
    when(chat.start).thenAnswer((_) async {});
    getIt.registerFactoryParam<ChatCubit, String, void>((_, _) => chat);
    final timeline = MockDriverNegotiationTimelineCubit();
    whenListen(
      timeline,
      const Stream<NegotiationTimelineState<DriverServiceRequest>>.empty(),
      initialState: const NegotiationTimelineState<DriverServiceRequest>(
        status: NegotiationTimelineStatus.none,
      ),
    );
    when(timeline.load).thenAnswer((_) async {});
    final timelineTokens = <String>[];
    getIt.registerFactoryParam<
      NegotiationTimelineCubit<DriverServiceRequest>,
      String,
      void
    >((conversationToken, _) {
      timelineTokens.add(conversationToken);
      return timeline;
    });
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      negotiationRouteHarness(
        UserType.driver,
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                openDriverNegotiationChat(context, TestDriverServiceRequest()),
            child: const Text('Conversar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Conversar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ChatPage<DriverServiceRequest>), findsOneWidget);
    expect(timelineTokens, ['conversation-1']);
    expect(find.text('Maria'), findsOneWidget);
  });

  testWidgets('a request without a conversation opens nothing', (tester) async {
    await tester.pumpWidget(
      negotiationRouteHarness(
        UserType.client,
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
      negotiationRouteHarness(
        UserType.client,
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

  testWidgets(
    'openDriverProfile opens DriverProfilePage and Pedir orçamento opens QuoteRequestPage',
    (tester) async {
      final profileCubit = MockDriverProfileCubit();
      whenListen(
        profileCubit,
        const Stream<DriverProfileState>.empty(),
        initialState: DriverProfileState(
          status: DriverProfileStatus.loaded,
          profile: testDriverProfile.copyWith(available: true),
        ),
      );
      when(profileCubit.loadProfile).thenAnswer((_) async {});
      getIt.registerFactoryParam<DriverProfileCubit, String, void>(
        (_, _) => profileCubit,
      );

      final quoteCubit = MockQuoteRequestCubit();
      whenListen(
        quoteCubit,
        const Stream<QuoteRequestState>.empty(),
        initialState: const QuoteRequestState(status: QuoteRequestStatus.loading),
      );
      when(quoteCubit.load).thenAnswer((_) async {});
      getIt.registerFactoryParam<QuoteRequestCubit, String, void>(
        (_, _) => quoteCubit,
      );
      addTearDown(getIt.reset);

      await tester.pumpWidget(
        negotiationRouteHarness(
          UserType.client,
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openDriverProfile(context, 'driver-1'),
              child: const Text('Perfil'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.byType(DriverProfilePage), findsOneWidget);
      expect(find.text('Carlos Souza'), findsOneWidget);

      await tester.tap(find.text('Pedir orçamento'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(QuoteRequestPage), findsOneWidget);
    },
  );

  testWidgets(
    'openQuoteRequest navigates to ChatPage when quote request is sent',
    (tester) async {
      final today = DateTime(2026, 10, 25);
      final readyState = QuoteRequestState(
        status: QuoteRequestStatus.ready,
        setup: const QuoteRequestSetup(
          driver: testDriverProfile,
          students: QuoteStudents(students: []),
          openRequests: [],
        ),
        draft: ServiceRequestDraft(
          driverToken: 'driver-1',
          desiredStartDate: today,
        ),
        today: today,
      );
      final sentRequest = TestClientServiceRequest(
        token: 'req-1',
        conversationToken: 'conv-created-1',
        driverToken: 'driver-1',
        driverName: 'Carlos Souza',
      );
      final quoteCubit = MockQuoteRequestCubit();
      whenListen(
        quoteCubit,
        Stream<QuoteRequestState>.fromIterable([
          readyState.copyWith(sentRequest: sentRequest),
        ]),
        initialState: readyState,
      );
      when(quoteCubit.load).thenAnswer((_) async {});
      getIt.registerFactoryParam<QuoteRequestCubit, String, void>(
        (_, _) => quoteCubit,
      );

      final chat = MockChatCubit();
      whenListen(
        chat,
        const Stream<ChatState>.empty(),
        initialState: const ChatState(status: ChatStatus.ready),
      );
      when(chat.start).thenAnswer((_) async {});
      final openedChats = <String>[];
      getIt.registerFactoryParam<ChatCubit, String, void>((token, _) {
        openedChats.add(token);
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
      getIt.registerFactoryParam<
        NegotiationTimelineCubit<ClientServiceRequest>,
        String,
        void
      >((_, _) => timeline);
      addTearDown(getIt.reset);

      await tester.pumpWidget(
        negotiationRouteHarness(
          UserType.client,
          Builder(
            builder: (context) => TextButton(
              onPressed: () => openQuoteRequest(context, 'driver-1'),
              child: const Text('Pedir orçamento'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pedir orçamento'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage<ClientServiceRequest>), findsOneWidget);
      expect(openedChats, ['conv-created-1']);
      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.text('Motorista'), findsOneWidget);
      expect(find.byTooltip('Ver perfil do motorista'), findsOneWidget);
    },
  );
}
