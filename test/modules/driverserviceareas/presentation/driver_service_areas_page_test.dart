import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driverserviceareas/presentation/cubit/driver_service_areas_cubit.dart';
import 'package:vanep_mobile/modules/driverserviceareas/presentation/cubit/driver_service_areas_state.dart';
import 'package:vanep_mobile/modules/driverserviceareas/presentation/pages/driver_service_areas_page.dart';

import '../driver_service_areas_fixtures.dart';

class MockDriverServiceAreasCubit
    extends MockCubit<DriverServiceAreasState>
    implements DriverServiceAreasCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

Widget harness(DriverServiceAreasCubit cubit, PlaceAutocompleteController auto) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<DriverServiceAreasCubit>.value(
      value: cubit,
      child: DriverServiceAreasPage(autocomplete: auto),
    ),
  );
}

void main() {
  late MockDriverServiceAreasCubit cubit;
  late PlaceAutocompleteController autocomplete;

  setUp(() {
    cubit = MockDriverServiceAreasCubit();
    final datasource = MockPlaceAutocompleteDataSource();
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([]));
    autocomplete = PlaceAutocompleteController(datasource: datasource);
  });

  tearDown(() => autocomplete.dispose());

  void seed(DriverServiceAreasState state) {
    whenListen(
      cubit,
      const Stream<DriverServiceAreasState>.empty(),
      initialState: state,
    );
  }

  testWidgets('shows the empty state when nothing is registered', (
    tester,
  ) async {
    seed(const DriverServiceAreasState());

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('Nenhuma região cadastrada ainda.'), findsOneWidget);
  });

  testWidgets('lists the drafts', (tester) async {
    seed(const DriverServiceAreasState(drafts: [testQnl5Draft]));

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('QNL 5'), findsOneWidget);
  });

  testWidgets('warns and disables adding once ten regions are listed', (
    tester,
  ) async {
    seed(DriverServiceAreasState(drafts: draftsOfSize(10)));

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('Você atingiu o máximo de 10 regiões.'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  /// A recusa do backend precisa chegar ao motorista sem apagar o que ele
  /// escolheu — a seleção continua na tela para ele trocar.
  testWidgets('shows the backend message and keeps the selection', (
    tester,
  ) async {
    seed(
      const DriverServiceAreasState(
        drafts: [testQnl5Draft],
        failure: ServiceAreaFailure.districtRequired,
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(
      find.text(
        'Esta cidade exige escolher um bairro ou região, não a cidade inteira.',
      ),
      findsOneWidget,
    );
    expect(find.text('QNL 5'), findsOneWidget);
  });

  testWidgets('cannot save an empty set', (tester) async {
    seed(const DriverServiceAreasState());

    await tester.pumpWidget(harness(cubit, autocomplete));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('removing a draft asks the cubit', (tester) async {
    seed(const DriverServiceAreasState(drafts: [testQnl5Draft]));
    when(() => cubit.removeDraft(any())).thenReturn(null);

    await tester.pumpWidget(harness(cubit, autocomplete));
    await tester.tap(find.byIcon(Icons.close));

    verify(() => cubit.removeDraft('place-qnl5')).called(1);
  });
}
