import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_form_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/widgets/dependent_address_field.dart';

import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const qnl5 = PlaceSuggestion(
  placeId: 'place-qnl5',
  primaryText: 'QNL 5 Conjunto A',
  secondaryText: 'Taguatinga, Brasília - DF',
);

const helenaWithAddress = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  birthDate: '2015-03-22',
  address: TestDependentAddress(complement: 'Casa 2'),
);

Widget harness({Dependent? dependent}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => DependentFormPage(dependent: dependent),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late MockCreateDependent createDependent;
  late MockUpdateDependent updateDependent;
  late MockPlaceAutocompleteDataSource placesDatasource;

  setUpAll(registerDependentFallbackValues);

  setUp(() async {
    await getIt.reset();
    createDependent = MockCreateDependent();
    updateDependent = MockUpdateDependent();
    placesDatasource = MockPlaceAutocompleteDataSource();
    when(
      () => placesDatasource.findSuggestions(any(), any()),
    ).thenAnswer((_) async => const Ok([qnl5]));

    getIt
      ..registerFactoryParam<DependentFormCubit, Dependent?, void>(
        (dependent, _) => DependentFormCubit(
          createDependent: createDependent,
          updateDependent: updateDependent,
          dependent: dependent,
        ),
      )
      ..registerFactory<PlaceAutocompleteController>(
        () => PlaceAutocompleteController(
          datasource: placesDatasource,
          debounce: const Duration(milliseconds: 10),
        ),
      );
  });

  tearDown(getIt.reset);

  Finder fieldLabeled(String label) => find.descendant(
    of: find.widgetWithText(VanepTextField, label),
    matching: find.byType(TextField),
  );

  Future<void> openForm(WidgetTester tester, {Dependent? dependent}) async {
    await tester.pumpWidget(harness(dependent: dependent));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> pickQnl5(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar endereço'),
      'qnl 5',
    );
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump();
    await tester.tap(find.text('QNL 5 Conjunto A'));
    await tester.pump();
  }

  testWidgets('a new dependent starts with an empty form', (tester) async {
    await openForm(tester);

    expect(find.text('Novo dependente'), findsOneWidget);
    expect(find.text('Selecionar data'), findsOneWidget);
    expect(find.text('Nenhum endereço informado.'), findsOneWidget);
    expect(find.byType(DependentAddressSummary), findsNothing);
  });

  testWidgets('editing prefills the fields from the dependent', (tester) async {
    await openForm(tester, dependent: helenaWithAddress);

    expect(find.text('Editar dependente'), findsOneWidget);
    expect(find.text('Helena Souza'), findsOneWidget);
    expect(find.text('QNL 5 Conjunto A'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Casa 2'), findsOneWidget);
    expect(find.byTooltip('Limpar data'), findsOneWidget);
  });

  testWidgets('saving without a name shows the local error', (tester) async {
    await openForm(tester);

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(find.text('Informe o nome do dependente.'), findsOneWidget);
    verifyNever(() => createDependent(any()));
  });

  testWidgets('picking a place shows the number and complement fields', (
    tester,
  ) async {
    await openForm(tester);

    await pickQnl5(tester);

    expect(find.byType(DependentAddressSummary), findsOneWidget);
    expect(find.text('Número'), findsOneWidget);
    expect(find.text('Complemento'), findsOneWidget);
    expect(find.text('Nenhum endereço informado.'), findsNothing);
  });

  testWidgets('removing the address brings the empty label back', (
    tester,
  ) async {
    await openForm(tester, dependent: helenaWithAddress);

    await tester.tap(find.byTooltip('Remover endereço'));
    await tester.pump();

    expect(find.byType(DependentAddressSummary), findsNothing);
    expect(find.text('Nenhum endereço informado.'), findsOneWidget);
  });

  testWidgets('clearing the birth date removes the clear button', (
    tester,
  ) async {
    await openForm(tester, dependent: helenaWithAddress);

    await tester.tap(find.byTooltip('Limpar data'));
    await tester.pump();

    expect(find.byTooltip('Limpar data'), findsNothing);
    expect(find.text('Selecionar data'), findsOneWidget);
  });

  testWidgets('choosing a gender offers a way to clear it', (tester) async {
    await openForm(tester);

    await tester.tap(find.text('Feminino'));
    await tester.pump();
    expect(find.text('Não informar'), findsOneWidget);

    await tester.tap(find.text('Não informar'));
    await tester.pump();
    expect(find.text('Não informar'), findsNothing);
  });

  testWidgets('picking a birth date from the calendar fills it', (
    tester,
  ) async {
    await openForm(tester);

    await tester.tap(find.text('Selecionar data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar data'), findsNothing);
    expect(find.byTooltip('Limpar data'), findsOneWidget);
  });

  testWidgets('dismissing the calendar keeps the date empty', (tester) async {
    await openForm(tester);

    await tester.tap(find.text('Selecionar data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar data'), findsOneWidget);
  });

  testWidgets('a saved dependent with an address closes the form', (
    tester,
  ) async {
    when(() => createDependent(any())).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
    );
    await openForm(tester);

    await tester.enterText(fieldLabeled('Nome'), 'Helena Souza');
    await pickQnl5(tester);
    await tester.enterText(fieldLabeled('Número'), '340');
    await tester.enterText(fieldLabeled('Complemento'), 'Bloco B');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final draft =
        verify(() => createDependent(captureAny())).captured.single
            as DependentDraft;
    expect(draft.name, 'Helena Souza');
    expect(draft.address!.placeId, 'place-qnl5');
    expect(draft.address!.number, '340');
    expect(draft.address!.complement, 'Bloco B');
    expect(find.byType(DependentFormView), findsNothing);
    expect(find.text('Dependente salvo.'), findsOneWidget);
  });

  testWidgets('a backend address error is shown under the address field', (
    tester,
  ) async {
    when(
      () => updateDependent(
        snapshot: any(named: 'snapshot'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer(
      (_) async => const Err<DependentFailure, Dependent>(
        DependentValidationFailure(
          detail: 'Revise o endereço.',
          messagesByField: {
            DependentField.address: 'Endereço não reconhecido.',
          },
        ),
      ),
    );
    await openForm(tester, dependent: helenaWithAddress);

    await tester.enterText(fieldLabeled('Número'), '99');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Endereço não reconhecido.'), findsOneWidget);
    expect(find.text('Revise o endereço.'), findsOneWidget);
    expect(find.byType(DependentFormView), findsOneWidget);
    final draft =
        verify(
              () => updateDependent(
                snapshot: helenaWithAddress,
                draft: captureAny(named: 'draft'),
              ),
            ).captured.single
            as DependentDraft;
    expect(draft.address!.number, '99');
  });

  test('asIsoDate pads month and day', () {
    expect(asIsoDate(DateTime(2015, 3, 2)), '2015-03-02');
  });
}
