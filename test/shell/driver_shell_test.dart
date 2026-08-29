import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/profile_page.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/profile/profile_mocks.dart';

Widget harness(
  DriverHomeCubit cubit,
  AuthCubit authCubit,
  ProfileSummaryCubit profileSummaryCubit,
) {
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
      child: const DriverShell(profile: FakeUserProfile()),
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
}
