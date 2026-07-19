import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/driver_card.dart';
import 'package:vanep_mobile/modules/drivers/presentation/widgets/drivers_home_body.dart';

import '../drivers_fixtures.dart';
import 'drivers_presentation_mocks.dart';

Widget _harness(DriversCubit cubit) {
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
        child: const DriversHomeBody(),
      ),
    ),
  );
}

void _emit(DriversCubit cubit, DriversState state) =>
    whenListen(cubit, Stream<DriversState>.empty(), initialState: state);

void main() {
  late MockDriversCubit cubit;

  setUp(() => cubit = MockDriversCubit());

  testWidgets('shows a spinner while loading', (tester) async {
    _emit(cubit, const DriversState(status: DriversStatus.loading));

    await tester.pumpWidget(_harness(cubit));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the loaded drivers', (tester) async {
    _emit(
      cubit,
      const DriversState(
        status: DriversStatus.loaded,
        drivers: testRecentDrivers,
      ),
    );

    await tester.pumpWidget(_harness(cubit));

    expect(find.byType(DriverCard), findsNWidgets(2));
  });

  testWidgets('shows the empty message when there are no drivers', (
    tester,
  ) async {
    _emit(cubit, const DriversState(status: DriversStatus.loaded));

    await tester.pumpWidget(_harness(cubit));

    expect(find.text('Nenhum motorista encontrado.'), findsOneWidget);
  });

  testWidgets('retry triggers a reload on error', (tester) async {
    _emit(cubit, const DriversState(status: DriversStatus.error));
    when(() => cubit.loadRecentDrivers()).thenAnswer((_) async {});

    await tester.pumpWidget(_harness(cubit));
    await tester.tap(find.text('Tentar novamente'));

    verify(() => cubit.loadRecentDrivers()).called(1);
  });
}
