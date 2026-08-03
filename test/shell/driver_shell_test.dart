import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

import '../modules/auth/auth_fixtures.dart';

Widget harness(DriverHomeCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<DriverHomeCubit>.value(
      value: cubit,
      child: const DriverShell(profile: FakeUserProfile()),
    ),
  );
}

void main() {
  late DriverHomeCubit cubit;

  setUp(() {
    cubit = DriverHomeCubit()..seedToday(shiftStartTime: '6h00');
  });

  tearDown(() => cubit.close());

  testWidgets('starts on the home tab with the greeting', (tester) async {
    await tester.pumpWidget(harness(cubit));

    expect(find.text('Olá, Ana!'), findsOneWidget);
  });

  testWidgets('switches to the Propostas tab showing the coming soon view', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit));

    await tester.tap(find.text('Propostas'));
    await tester.pumpAndSettle();

    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('switches to the Alunos tab showing the coming soon view', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit));

    await tester.tap(find.text('Alunos'));
    await tester.pumpAndSettle();

    expect(find.text('Em breve'), findsOneWidget);
  });
}
