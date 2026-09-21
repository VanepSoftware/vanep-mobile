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
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_vans_tab.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/profile/profile_mocks.dart';

Widget harness(
  DriverHomeCubit cubit,
  AuthCubit authCubit,
  ProfileSummaryCubit profileSummaryCubit, {
  List<OnboardingStep> pendingSteps = const [],
  Future<void> Function(BuildContext)? openServiceAreas,
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
        BlocProvider<ProfileSummaryCubit>.value(value: profileSummaryCubit),
      ],
      child: DriverShell(
        profile: FakeUserProfile(pendingOnboardingSteps: pendingSteps),
        openServiceAreas: openServiceAreas ?? (_) async {},
      ),
    ),
  );
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

  testWidgets('bottom bar offers home, vans, proposals and students', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    expect(bottomNavLabels(tester), [
      'Início',
      'Vans',
      'Propostas',
      'Alunos',
    ]);
  });

  testWidgets('switches to the Vans tab showing the vans hub', (tester) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Vans'));
    await tester.pumpAndSettle();

    expect(find.byType(DriverVansTab), findsOneWidget);
    expect(find.text('Minhas vans'), findsOneWidget);
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
    await tester.tap(find.text('Onde você atende'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    verify(() => authCubit.refreshSessionProfile()).called(1);
  });

  testWidgets('the Propostas tab shows proposals and contracts coming soon', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Propostas'));
    await tester.pumpAndSettle();

    expect(find.text('Propostas e contratos'), findsOneWidget);
    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('switches to the Alunos tab showing the coming soon view', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Alunos'));
    await tester.pumpAndSettle();

    expect(find.text('Em breve'), findsOneWidget);
  });

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
}
