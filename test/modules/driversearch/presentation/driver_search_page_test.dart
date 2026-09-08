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
import 'package:vanep_mobile/modules/driversearch/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driversearch/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/pages/driver_search_page.dart';

class MockDriverSearchCubit extends MockCubit<DriverSearchState>
    implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const rankedResults = [
  DriverSearchResult(
    token: 'd1',
    name: 'Exato QNL 5',
    serviceAreas: ['Brasília', 'Taguatinga Norte', 'QNL 5'],
  ),
  DriverSearchResult(token: 'd2', name: 'Setor L Norte'),
  DriverSearchResult(token: 'd3', name: 'Taguatinga'),
  DriverSearchResult(token: 'd4', name: 'Cidade inteira'),
];

Widget harness(DriverSearchCubit cubit, PlaceAutocompleteController auto) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<DriverSearchCubit>.value(
      value: cubit,
      child: DriverSearchPage(autocomplete: auto),
    ),
  );
}

void main() {
  late MockDriverSearchCubit cubit;
  late PlaceAutocompleteController autocomplete;

  setUp(() {
    cubit = MockDriverSearchCubit();
    final datasource = MockPlaceAutocompleteDataSource();
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([]));
    autocomplete = PlaceAutocompleteController(datasource: datasource);
  });

  tearDown(() => autocomplete.dispose());

  void seed(DriverSearchState state) {
    whenListen(
      cubit,
      const Stream<DriverSearchState>.empty(),
      initialState: state,
    );
  }

  testWidgets('offers a single search box', (tester) async {
    seed(const DriverSearchState());

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('renders results in the order the API returned', (tester) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .where((label) => rankedResults.any((driver) => driver.name == label))
        .toList();

    expect(names, [
      'Exato QNL 5',
      'Setor L Norte',
      'Taguatinga',
      'Cidade inteira',
    ]);
  });

  testWidgets('shows the empty state when nobody covers the place', (
    tester,
  ) async {
    seed(const DriverSearchState(status: DriverSearchStatus.loaded));

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(
      find.text('Nenhum motorista atende este local ainda.'),
      findsOneWidget,
    );
  });

  testWidgets('an unresolved place is not shown as an empty result', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.failed,
        failure: DriverSearchFailure.placeNotResolved,
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(
      find.text(
        'Não foi possível interpretar este local. Escolha outra sugestão.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Nenhum motorista atende este local ainda.'),
      findsNothing,
    );
  });

  testWidgets('a rate limit has its own message', (tester) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.failed,
        failure: DriverSearchFailure.rateLimited,
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(
      find.text('Muitas buscas. Aguarde um momento e tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('shows progress while searching', (tester) async {
    seed(const DriverSearchState(status: DriverSearchStatus.searching));

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a failed page keeps the results and offers a retry', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loadMoreFailed,
        results: rankedResults,
        failure: DriverSearchFailure.network,
      ),
    );
    when(() => cubit.retryLoadMore()).thenAnswer((_) async {});

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('Exato QNL 5'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    verify(() => cubit.retryLoadMore()).called(1);
  });

  testWidgets('shows where the driver operates under the name', (tester) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('Brasília · Taguatinga · QNL'), findsOneWidget);
  });
}
