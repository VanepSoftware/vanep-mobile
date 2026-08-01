import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_home_tab.dart';

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
    home: Scaffold(
      body: BlocProvider<DriverHomeCubit>.value(
        value: cubit,
        child: const DriverHomeTab(displayName: 'Carlos Souza'),
      ),
    ),
  );
}

void main() {
  late DriverHomeCubit cubit;

  setUp(() {
    cubit = DriverHomeCubit()..seedToday(shiftStartTime: '6h00');
  });

  tearDown(() => cubit.close());

  testWidgets('shows the greeting with the first name and shift subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit));

    expect(find.text('Olá, Carlos!'), findsOneWidget);
    expect(find.text('Seu expediente começa às 6h00'), findsOneWidget);
  });

  testWidgets('start route toggles the badge and the button label', (
    tester,
  ) async {
    await tester.pumpWidget(harness(cubit));

    expect(find.text('Fora do expediente'), findsOneWidget);
    expect(find.text('Iniciar rota'), findsOneWidget);

    await tester.tap(find.text('Iniciar rota'));
    await tester.pumpAndSettle();

    expect(find.text('Em expediente'), findsOneWidget);
    expect(find.text('Encerrar rota'), findsOneWidget);
  });

  testWidgets('location sharing toggle updates the cubit', (tester) async {
    await tester.pumpWidget(harness(cubit));

    expect(cubit.state.sharingLocation, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(cubit.state.sharingLocation, isTrue);
  });
}
