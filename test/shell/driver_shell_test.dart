import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/onboarding_step.dart';
import 'package:vanep_mobile/modules/driver_service_areas/presentation/widgets/service_areas_onboarding_banner.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/conversations/domain/entities/conversation.dart';
import 'package:vanep_mobile/modules/conversations/presentation/cubit/conversations_inbox_cubit.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/repositories/driver_home_repository.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/pages/van_central_tab.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/driver_proposals_tab.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/modules/push_notifications/domain/value_objects/push_navigation_target.dart';
import 'package:vanep_mobile/modules/push_notifications/presentation/cubit/push_navigation_cubit.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/conversations/conversations_fixtures.dart';
import '../modules/conversations/conversations_mocks.dart';
import '../modules/driver_proposals/driver_proposals_mocks.dart';
import '../modules/profile/profile_mocks.dart';
import '../modules/push_notifications/push_notifications_fixtures.dart';
import '../modules/driver_van_central/driver_van_central_mocks.dart';
import '../modules/driver_van_central/driver_van_central_fixtures.dart';

class _StubHomeRepository implements DriverHomeRepository {
  _StubHomeRepository(this.data);
  final DriverHomeData data;
  @override
  Future<DriverHomeData> load() async => data;
  @override
  Future<void> startTrip(String tripId) async {}
  @override
  Future<void> confirmStop(StopConfirmation confirmation) async {}
}

Widget harness(
  DriverHomeCubit cubit,
  AuthCubit authCubit,
  ProfileSummaryCubit profileSummaryCubit, {
  List<OnboardingStep> pendingSteps = const [],
  Future<void> Function(BuildContext)? openServiceAreas,
  ConversationsInboxCubit? conversationsCubit,
  Future<void> Function(BuildContext, Conversation)? openConversationChat,
  DriverNegotiationsCubit? negotiationsCubit,
  VanCentralCubit? vanCentralCubit,
  Future<void> Function(BuildContext, DriverVan)? openVanStudents,
  Future<void> Function(BuildContext, DriverVan)? openVanDocuments,
  Future<void> Function(BuildContext)? openProfessionalData,
  PushNavigationCubit? pushNavigationCubit,
  Future<void> Function(BuildContext, ChatPushTarget)? openPushChat,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DriverHomeCubit>.value(value: cubit),
        BlocProvider<VanCentralCubit>.value(
          value: vanCentralCubit ?? readyVanCentralCubit(),
        ),
        BlocProvider<ProfileSummaryCubit>.value(value: profileSummaryCubit),
        BlocProvider<ConversationsInboxCubit>.value(
          value: conversationsCubit ?? readyConversationsCubit(),
        ),
        BlocProvider<DriverNegotiationsCubit>.value(
          value: negotiationsCubit ?? readyNegotiationsCubit(),
        ),
        BlocProvider<PushNavigationCubit>.value(
          value: pushNavigationCubit ?? PushNavigationCubit(),
        ),
      ],
      child: DriverShell(
        profile: FakeUserProfile(pendingOnboardingSteps: pendingSteps),
        openServiceAreas: openServiceAreas ?? (_) async {},
        openMyVans: (_) async {},
        openVanRegistration: (_) async {},
        openVanStudents: openVanStudents ?? (_, _) async {},
        openVanDocuments: openVanDocuments ?? (_, _) async {},
        openProfessionalData: openProfessionalData ?? (_) async {},
        openConversationChat: openConversationChat ?? (_, _) async {},
        proposalsActions: DriverProposalsTabActions(
          onOpenRequest: (_) async {},
          onOpenProposal: (_) async {},
        ),
        openPushChat: openPushChat ?? (_, _) async {},
      ),
    ),
  );
}

VanCentralCubit readyVanCentralCubit() {
  final cubit = MockVanCentralCubit();
  whenListen(
    cubit,
    const Stream<VanCentralState>.empty(),
    initialState: const VanCentralState(
      status: VanCentralStatus.loaded,
      vans: [firstVan],
      occupancy: testOccupancy,
      attendance: testAttendance,
      serviceAreas: testServiceAreas,
    ),
  );
  when(() => cubit.refresh()).thenAnswer((_) async {});
  return cubit;
}

List<String> bottomNavLabels(WidgetTester tester) {
  final nav = tester.widget<VanepBottomNav>(find.byType(VanepBottomNav));
  return [for (final item in nav.items) item.label];
}

void main() {
  late DriverHomeCubit cubit;
  late MockAuthCubit authCubit;
  late MockProfileSummaryCubit profileSummaryCubit;

  setUp(() {
    cubit = DriverHomeCubit()..seedToday(shiftStartTime: '6h00');
    authCubit = MockAuthCubit();
    profileSummaryCubit = MockProfileSummaryCubit();
    whenListen(
      profileSummaryCubit,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    when(() => authCubit.refreshSessionProfile()).thenAnswer((_) async {});
    when(() => profileSummaryCubit.refresh(any())).thenAnswer((_) async {});
  });

  tearDown(() => cubit.close());

  testWidgets('starts on the home tab with the greeting', (tester) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    expect(find.text('Olá, Ana!'), findsOneWidget);
  });

  testWidgets('bottom bar offers home, vans, proposals and messages', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    expect(bottomNavLabels(tester), [
      'Início',
      'Vans',
      'Propostas',
      'Mensagens',
    ]);
  });

  testWidgets('switches to the Vans tab showing the vans hub', (tester) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Vans'));
    await tester.pumpAndSettle();

    expect(find.byType(VanCentralTab), findsOneWidget);
    expect(find.text('Vans'), findsWidgets);
  });

  testWidgets('where you operate opens service areas and rereads profile', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        openServiceAreas: (_) async => opened = true,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Vans'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Áreas de atendimento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áreas de atendimento'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    verify(() => authCubit.refreshSessionProfile()).called(1);
  });

  testWidgets('the Propostas tab loads and shows the negotiations', (
    tester,
  ) async {
    final negotiationsCubit = readyNegotiationsCubit();
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        negotiationsCubit: negotiationsCubit,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Propostas'));
    await tester.pumpAndSettle();

    expect(find.byType(DriverProposalsTab), findsOneWidget);
    expect(find.text('Negociações'), findsOneWidget);
    expect(find.text('Maria · Theo e Alice'), findsOneWidget);
    expect(find.text('Em breve'), findsNothing);
    verify(() => negotiationsCubit.load()).called(1);
  });

  testWidgets(
    'students opens the selected van and refreshes the hub on return',
    (tester) async {
      final centralCubit = readyVanCentralCubit();
      final opened = <DriverVan>[];
      await tester.pumpWidget(
        harness(
          cubit,
          authCubit,
          profileSummaryCubit,
          vanCentralCubit: centralCubit,
          openVanStudents: (_, van) async => opened.add(van),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Vans'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Alunos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alunos'));
      await tester.pumpAndSettle();

      expect(opened, [firstVan]);
      expect(find.byType(VanepComingSoonPage), findsNothing);
      verify(() => centralCubit.refresh()).called(1);
    },
  );

  testWidgets(
    'van documents opens the selected van and refreshes the hub on return',
    (tester) async {
      final centralCubit = readyVanCentralCubit();
      final opened = <DriverVan>[];
      await tester.pumpWidget(
        harness(
          cubit,
          authCubit,
          profileSummaryCubit,
          vanCentralCubit: centralCubit,
          openVanDocuments: (_, van) async => opened.add(van),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Vans'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Documentos da van'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Documentos da van'));
      await tester.pumpAndSettle();

      expect(opened, [firstVan]);
      expect(find.byType(VanepComingSoonPage), findsNothing);
      verify(() => centralCubit.refresh()).called(1);
    },
  );

  testWidgets('the menu button opens the account drawer and refreshes it', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Dados profissionais'), findsOneWidget);
    verify(() => authCubit.refreshSessionProfile()).called(1);
    verify(() => profileSummaryCubit.refresh(any())).called(1);
  });

  testWidgets(
    'professional data opens from the menu and refreshes the van central',
    (tester) async {
      final centralCubit = readyVanCentralCubit();
      var opened = 0;
      await tester.pumpWidget(
        harness(
          cubit,
          authCubit,
          profileSummaryCubit,
          vanCentralCubit: centralCubit,
          openProfessionalData: (_) async => opened++,
        ),
      );

      await tester.tap(find.byTooltip('Abrir menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dados profissionais'));
      await tester.pumpAndSettle();

      expect(opened, 1);
      verify(() => centralCubit.refresh()).called(1);
    },
  );

  testWidgets('the Mensagens tab loads the conversations and opens a chat', (
    tester,
  ) async {
    final conversationsCubit = readyConversationsCubit([testConversation]);
    final opened = <Conversation>[];
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        conversationsCubit: conversationsCubit,
        openConversationChat: (_, conversation) async =>
            opened.add(conversation),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Mensagens'));
    await tester.pumpAndSettle();
    verify(() => conversationsCubit.loadConversations()).called(1);

    await tester.tap(find.text('Ana Cliente'));
    await tester.pumpAndSettle();

    expect(opened, [testConversation]);
  });

  testWidgets('the bell opens the notifications coming soon page', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.byTooltip('Notificações'));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
  });

  testWidgets('offers the service areas screen when the step is pending', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        pendingSteps: const [OnboardingStep.serviceArea],
      ),
    );

    expect(find.byType(ServiceAreasOnboardingBanner), findsOneWidget);
  });

  testWidgets('does not offer it when nothing is pending', (tester) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    expect(find.byType(ServiceAreasOnboardingBanner), findsNothing);
  });

  testWidgets('skipping keeps full access to the app', (tester) async {
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        pendingSteps: const [OnboardingStep.serviceArea],
      ),
    );

    await tester.tap(find.text('Depois'));
    await tester.pumpAndSettle();

    expect(find.byType(ServiceAreasOnboardingBanner), findsNothing);
    expect(find.text('Olá, Ana!'), findsOneWidget);
  });

  testWidgets('accepting opens the service areas screen', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        pendingSteps: const [OnboardingStep.serviceArea],
        openServiceAreas: (_) async => opened = true,
      ),
    );

    await tester.tap(find.text('Cadastrar agora'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
  });

  testWidgets('rereads the pending steps after the areas screen closes', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        pendingSteps: const [OnboardingStep.serviceArea],
        openServiceAreas: (_) async {},
      ),
    );

    await tester.tap(find.text('Cadastrar agora'));
    await tester.pumpAndSettle();

    verify(() => authCubit.refreshSessionProfile()).called(1);
  });

  testWidgets('the service areas card stays below the status bar', (
    tester,
  ) async {
    const statusBar = 48.0;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.padding = const FakeViewPadding(top: statusBar);
    tester.view.viewPadding = const FakeViewPadding(top: statusBar);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      harness(
        cubit,
        authCubit,
        profileSummaryCubit,
        pendingSteps: const [OnboardingStep.serviceArea],
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Falta dizer onde você atende');
    expect(tester.getTopLeft(title).dy, greaterThan(statusBar));

    final tabPadding = MediaQuery.paddingOf(
      tester.element(find.byType(IndexedStack)),
    );
    expect(tabPadding.top, 0);

    await tester.tap(find.text('Depois'));
    await tester.pumpAndSettle();

    expect(
      MediaQuery.paddingOf(tester.element(find.byType(IndexedStack))).top,
      statusBar,
    );
  });

  group('push notification targets', () {
    testWidgets('a chat push pending before mount opens the chat', (
      tester,
    ) async {
      final pushNavigationCubit = PushNavigationCubit()
        ..openTarget(chatPushTarget);
      addTearDown(pushNavigationCubit.close);
      final openedChats = <ChatPushTarget>[];
      await tester.pumpWidget(
        harness(
          cubit,
          authCubit,
          profileSummaryCubit,
          pushNavigationCubit: pushNavigationCubit,
          openPushChat: (_, target) async => openedChats.add(target),
        ),
      );
      await tester.pumpAndSettle();

      expect(openedChats, [chatPushTarget]);
      expect(pushNavigationCubit.state, isNull);
    });

    for (final target in const [ProposalPushTarget(), ContractPushTarget()]) {
      testWidgets('a ${target.runtimeType} opens the Propostas tab', (
        tester,
      ) async {
        final pushNavigationCubit = PushNavigationCubit();
        addTearDown(pushNavigationCubit.close);
        final negotiationsCubit = readyNegotiationsCubit();
        await tester.pumpWidget(
          harness(
            cubit,
            authCubit,
            profileSummaryCubit,
            negotiationsCubit: negotiationsCubit,
            pushNavigationCubit: pushNavigationCubit,
          ),
        );

        pushNavigationCubit.openTarget(target);
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<VanepBottomNav>(find.byType(VanepBottomNav))
              .currentIndex,
          driverShellProposalsTabIndex,
        );
        expect(find.byType(DriverProposalsTab), findsOneWidget);
        verify(() => negotiationsCubit.load()).called(1);
      });
    }
  });

  testWidgets(
    'tapping Adicionar alunos on home opens Alunos coming soon page',
    (tester) async {
      final approvedCubit = DriverHomeCubit(
        repository: _StubHomeRepository(
          const DriverHomeData(registration: RegistrationStatus.approved),
        ),
      );
      addTearDown(approvedCubit.close);

      await tester.pumpWidget(
        harness(approvedCubit, authCubit, profileSummaryCubit),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Adicionar alunos'));
      await tester.tap(find.text('Adicionar alunos'));
      await tester.pumpAndSettle();

      expect(find.byType(VanepComingSoonPage), findsOneWidget);
    },
  );
}
