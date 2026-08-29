import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/onboarding_step.dart';
import 'package:vanep_mobile/modules/driverserviceareas/presentation/widgets/service_areas_onboarding_banner.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/profile_page.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/profile/profile_mocks.dart';

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

PlaceAutocompleteController buildAutocomplete() {
  final datasource = MockPlaceAutocompleteDataSource();
  when(() => datasource.findSuggestions(any(), any()))
      .thenAnswer((_) async => const Ok([]));
  return PlaceAutocompleteController(datasource: datasource);
}

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
        placeAutocomplete: buildAutocomplete(),
        openServiceAreas:
            openServiceAreas ?? (_) async {},
      ),
    ),
  );
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

  testWidgets('switches to the Propostas tab showing the coming soon view', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Propostas'));
    await tester.pumpAndSettle();

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

  testWidgets('shows the real profile page on the profile tab', (tester) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(VanepComingSoon), findsNothing);
  });

  testWidgets('refreshes session and summary when opening the profile tab', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit, authCubit, profileSummaryCubit));

    await tester.tap(find.bySemanticsLabel('Perfil'));
    await tester.pumpAndSettle();

    verify(() => authCubit.refreshSessionProfile()).called(1);
    verify(() => profileSummaryCubit.refresh(any())).called(1);
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

  /// Recusar é permitido: o onboarding é convite, não porteira.
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
}
