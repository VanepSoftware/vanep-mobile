import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/dependent_dto.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/pages/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_driver_card.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/widgets/find_van_skeleton.dart';

class MockDriverSearchCubit extends MockCubit<DriverSearchState>
    implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const rankedResults = [
  DriverSearchResult(
    token: 'd1',
    name: 'Exato QNL 5',
    serviceAreas: ['Brasília', 'Taguatinga Norte', 'QNL 5'],
    available: true,
  ),
  DriverSearchResult(token: 'd2', name: 'Setor L Norte', available: true),
  DriverSearchResult(token: 'd3', name: 'Taguatinga', available: true),
  DriverSearchResult(token: 'd4', name: 'Cidade inteira', available: false),
];

const sampleAddress = PersonalAddress(
  token: 'addr-1',
  street: 'QNL 5 Conjunto F',
  neighborhood: 'QNL 5',
  cityName: 'Taguatinga',
  cityToken: 'city-1',
  stateUf: 'DF',
  countryIsoCode: 'BR',
);

const sampleDependents = [
  DependentDto(
    token: 'dep-1',
    name: 'Ana Silva',
    birthDate: '2018-03-10',
    isDefault: true,
    school: DependentSchoolDto(token: 'sch-1', name: 'Colégio Horizonte'),
  ),
  DependentDto(
    token: 'dep-2',
    name: 'Pedro Silva',
    birthDate: '2015-05-10',
  ),
];

Widget harness(
  DriverSearchCubit cubit,
  PlaceAutocompleteController auto, {
  ValueChanged<String>? onDriverSelected,
  ValueChanged<String>? onQuoteRequested,
  ValueChanged<String>? onInviteSubmitted,
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
    home: BlocProvider<DriverSearchCubit>.value(
      value: cubit,
      child: DriverSearchPage(
        autocomplete: auto,
        onDriverSelected: onDriverSelected,
        onQuoteRequested: onQuoteRequested,
        onInviteSubmitted: onInviteSubmitted,
      ),
    ),
  );
}

void main() {
  late MockDriverSearchCubit cubit;
  late PlaceAutocompleteController autocomplete;

  setUp(() {
    cubit = MockDriverSearchCubit();
    when(() => cubit.loadMore()).thenAnswer((_) async {});
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

  testWidgets('renders prototype header, route card and filter chips', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
        personalAddress: sampleAddress,
        dependents: sampleDependents,
        selectedDependentTokens: {'dep-1', 'dep-2'},
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('Vans'), findsOneWidget);
    expect(find.text('Quem atende o trajeto do seu filho'), findsOneWidget);
    expect(find.text('Tenho\nconvite'), findsOneWidget);
    expect(find.text('Casa · QNL 5 Conjunto F, QNL 5, Taguatinga'), findsOneWidget);
    expect(find.text('Colégio Horizonte'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Manhã'), findsNothing);
    expect(find.text('Tarde'), findsNothing);
    expect(find.text('Integral'), findsNothing);
    expect(find.text('Com vaga'), findsNothing);
    expect(find.text('4 motoristas atendem esse trajeto'), findsOneWidget);
  });

  testWidgets('tapping Filtros opens modal with dependents and toggles choice', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        dependents: sampleDependents,
        selectedDependentTokens: {'dep-1', 'dep-2'},
      ),
    );
    when(() => cubit.toggleDependent('dep-2')).thenReturn(null);

    await tester.pumpWidget(harness(cubit, autocomplete));
    await tester.tap(find.text('Filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Dependentes'), findsOneWidget);
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Pedro Silva'), findsOneWidget);

    await tester.tap(find.text('Pedro Silva'));
    await tester.pump();
    verify(() => cubit.toggleDependent('dep-2')).called(1);

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(find.text('Dependentes'), findsNothing);
  });

  testWidgets('tapping Embarque with custom origin offers Usar meu endereço', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        personalAddress: sampleAddress,
        originLabel: 'Outro Local',
      ),
    );
    when(() => cubit.useProfileOrigin()).thenReturn(null);

    await tester.pumpWidget(harness(cubit, autocomplete));
    await tester.tap(find.text('Embarque'));
    await tester.pumpAndSettle();

    expect(find.text('Usar meu endereço'), findsOneWidget);
    await tester.tap(find.text('Usar meu endereço'));
    await tester.pumpAndSettle();

    verify(() => cubit.useProfileOrigin()).called(1);
  });

  testWidgets('tapping destination opens place autocomplete sheet', (
    tester,
  ) async {
    seed(const DriverSearchState());

    await tester.pumpWidget(harness(cubit, autocomplete));
    await tester.tap(find.text('Destino'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Escola ou destino'), findsOneWidget);
  });

  testWidgets('tapping a card or Perfil opens driver profile', (tester) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );
    final selected = <String>[];

    await tester.pumpWidget(
      harness(cubit, autocomplete, onDriverSelected: selected.add),
    );
    await tester.tap(find.text('Setor L Norte'));

    expect(selected, ['d2']);
  });

  testWidgets('a result shows base price without vehicle or seat count', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: [
          DriverSearchResult(
            token: 'd1',
            name: 'Carlos Souza',
            rating: 4.9,
            experienceYears: 8,
            basePrice: 320,
            available: true,
            serviceAreas: ['QNL 5', 'Taguatinga'],
          ),
        ],
      ),
    );
    final requested = <String>[];

    await tester.pumpWidget(
      harness(cubit, autocomplete, onQuoteRequested: requested.add),
    );

    expect(find.text('a partir de'), findsOneWidget);
    expect(find.text('R\$\u00a0320'), findsOneWidget);
    expect(find.text('/mês'), findsOneWidget);
    expect(find.text('QNL 5 · Taguatinga'), findsOneWidget);
    expect(find.textContaining('lugares'), findsNothing);
    expect(find.text('4,9'), findsOneWidget);
    await tester.tap(find.text('Pedir orçamento'));

    expect(requested, ['d1']);
  });

  testWidgets('renders results in the order the API returned', (tester) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    final names = <String>[];
    for (final expected in [
      'Exato QNL 5',
      'Setor L Norte',
      'Taguatinga',
      'Cidade inteira',
    ]) {
      await tester.scrollUntilVisible(
        find.text(expected),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      names.add(expected);
    }

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

  testWidgets('shows skeleton list while searching', (tester) async {
    seed(const DriverSearchState(status: DriverSearchStatus.searching));

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.byType(FindVanSkeletonList), findsOneWidget);
    expect(find.byType(FindVanDriverCard), findsNothing);
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
    await tester.scrollUntilVisible(
      find.text('Tentar novamente'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
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

    expect(find.text('Brasília · Taguatinga Norte · QNL 5'), findsOneWidget);
  });

  testWidgets('sort button opens sort sheet and invokes setSortOrder', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );
    when(() => cubit.setSortOrder(DriverSearchSortOrder.lowestPrice))
        .thenReturn(null);

    await tester.pumpWidget(harness(cubit, autocomplete));
    await tester.tap(find.text('Mais próximos'));
    await tester.pumpAndSettle();

    expect(find.text('Ordenar motoristas'), findsOneWidget);
    await tester.tap(find.text('Menor preço'));
    await tester.pumpAndSettle();

    verify(() => cubit.setSortOrder(DriverSearchSortOrder.lowestPrice))
        .called(1);
  });

  testWidgets('tapping swap and filter chips invokes cubit actions', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );
    when(() => cubit.swapRoute()).thenReturn(null);

    await tester.pumpWidget(harness(cubit, autocomplete));
    await tester.tap(find.byIcon(Icons.swap_vert_rounded));
    await tester.pump();

    verify(() => cubit.swapRoute()).called(1);
  });

  testWidgets('orders available vans first and shows unavailable in red', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: [
          DriverSearchResult(
            token: 'd-full',
            name: 'Sem Vaga',
            available: false,
          ),
          DriverSearchResult(
            token: 'd-open',
            name: 'Com Vaga',
            available: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(harness(cubit, autocomplete));

    final openLabel = find.text('Com vaga disponível');
    final fullLabel = find.text('Sem vaga disponível');
    expect(openLabel, findsOneWidget);
    expect(fullLabel, findsOneWidget);
    expect(
      tester.getTopLeft(openLabel).dy,
      lessThan(tester.getTopLeft(fullLabel).dy),
    );

    final fullText = tester.widget<Text>(fullLabel);
    expect(fullText.style?.color, isNotNull);
    final openText = tester.widget<Text>(openLabel);
    expect(fullText.style?.color, isNot(equals(openText.style?.color)));
  });

  testWidgets('empty state provides clear search button', (tester) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: [],
        placeId: 'place-empty',
      ),
    );

    when(() => cubit.clearSearch()).thenReturn(null);

    await tester.pumpWidget(harness(cubit, autocomplete));

    expect(find.text('Nenhum motorista atende este local ainda.'), findsOneWidget);
    await tester.tap(find.text('Limpar busca'));
    await tester.pump();

    verify(() => cubit.clearSearch()).called(1);
  });

  testWidgets('applies bottom SafeArea to page and invite modal sheet', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: rankedResults,
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(top: 24, bottom: 32)),
        child: harness(cubit, autocomplete),
      ),
    );

    final pageSafeArea = tester.widget<SafeArea>(
      find.descendant(
        of: find.byType(DriverSearchPage),
        matching: find.byType(SafeArea),
      ),
    );
    expect(pageSafeArea.bottom, isTrue);

    await tester.tap(find.byIcon(Icons.qr_code_2_rounded));
    await tester.pumpAndSettle();

    final sheetSafeArea = tester.widget<SafeArea>(
      find.ancestor(
        of: find.text('Entrar com convite'),
        matching: find.byType(SafeArea),
      ),
    );
    expect(sheetSafeArea.top, isFalse);
    expect(sheetSafeArea.bottom, isTrue);
  });

  testWidgets(
    'place search sheet scrolls without overflowing when keyboard is open',
    (tester) async {
      final datasource = MockPlaceAutocompleteDataSource();
      when(() => datasource.findSuggestions(any(), any())).thenAnswer(
        (_) async => Ok([
          for (var i = 0; i < 6; i++)
            PlaceSuggestion(
              placeId: 'p-$i',
              primaryText: 'Colégio Estadual Horizonte Unidade $i',
              secondaryText: 'Taguatinga Norte, Brasília - DF',
            ),
        ]),
      );
      final localAutocomplete = PlaceAutocompleteController(
        datasource: datasource,
      );
      addTearDown(localAutocomplete.dispose);

      seed(const DriverSearchState(status: DriverSearchStatus.loaded));

      tester.view.physicalSize = const Size(360, 560);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 560),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
          child: harness(cubit, localAutocomplete),
        ),
      );

      await tester.tap(find.text('Buscar escola ou endereço'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Colégio');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(
        find.text('Colégio Estadual Horizonte Unidade 5'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('driver card footer wraps without overflow on narrow large-text view', (
    tester,
  ) async {
    seed(
      const DriverSearchState(
        status: DriverSearchStatus.loaded,
        results: [
          DriverSearchResult(
            token: 'd-tight',
            name: 'Carlos Souza',
            rating: 4.9,
            basePrice: 1320,
            experienceYears: 8,
            available: true,
            serviceAreas: ['Taguatinga'],
          ),
        ],
      ),
    );

    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 1200),
          textScaler: TextScaler.linear(1.5),
        ),
        child: harness(cubit, autocomplete),
      ),
    );

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Pedir orçamento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
