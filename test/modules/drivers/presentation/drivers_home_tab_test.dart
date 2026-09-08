import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/pages/drivers_home_tab.dart';

import '../drivers_fixtures.dart';
import 'drivers_presentation_mocks.dart';

Widget _harness(
  DriversCubit cubit,
  String displayName, {
  VoidCallback? onSearchTapped,
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
    home: Scaffold(
      body: BlocProvider<DriversCubit>.value(
        value: cubit,
        child: DriversHomeTab(
          displayName: displayName,
          onSearchTapped: onSearchTapped ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  late MockDriversCubit cubit;

  setUp(() {
    cubit = MockDriversCubit();
    whenListen(
      cubit,
      const Stream<DriversState>.empty(),
      initialState: const DriversState(
        status: DriversStatus.loaded,
        drivers: testRecentDrivers,
      ),
    );
  });

  testWidgets('greets the user by first name', (tester) async {
    await tester.pumpWidget(_harness(cubit, 'Maria Silva'));

    expect(find.text('Olá, Maria!'), findsOneWidget);
    expect(find.text('Sugestões perto de você'), findsOneWidget);
  });

  testWidgets('tapping the search field opens the search screen', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _harness(cubit, 'Maria Silva', onSearchTapped: () => opened = true),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
  });

  testWidgets('the search field never filters locally', (tester) async {
    await tester.pumpWidget(_harness(cubit, 'Maria Silva'));

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.readOnly, isTrue);
    verifyNever(() => cubit.search(any()));
  });
}
