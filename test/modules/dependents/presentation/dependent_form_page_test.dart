import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_cep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_gender_select.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/ui/vanep_postal_address_form.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_address_form_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_form_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';

import '../../ibge_locations/ibge_locations_fixture.dart';
import '../../ibge_locations/ibge_locations_mocks.dart';
import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

const helenaWithAddress = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  birthDate: '2015-03-22',
  gender: Gender.female,
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
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;

  setUpAll(registerDependentFallbackValues);

  setUp(() async {
    await getIt.reset();
    createDependent = MockCreateDependent();
    updateDependent = MockUpdateDependent();
    lookupCep = MockLookupCep();
    listStates = MockListStates();
    listCities = MockListCities();
    when(() => listStates()).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: const [fakeDfState])),
    );
    when(() => listCities(uf: any(named: 'uf'))).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: [fakeBrazilianCity()])),
    );

    getIt.registerFactoryParam<DependentFormCubit, Dependent?, void>(
      (dependent, _) => DependentFormCubit(
        createDependent: createDependent,
        updateDependent: updateDependent,
        lookupCep: lookupCep,
        listStates: listStates,
        listCities: listCities,
        cepLookupDebounce: Duration.zero,
        dependent: dependent,
      ),
    );
  });

  tearDown(getIt.reset);

  Finder fieldLabeled(String label) => find.descendant(
    of: find.widgetWithText(VanepTextField, label),
    matching: find.byType(TextField),
  );

  String textOf(WidgetTester tester, String label) {
    return tester.widget<TextField>(fieldLabeled(label)).controller!.text;
  }

  Future<void> openForm(WidgetTester tester, {Dependent? dependent}) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(harness(dependent: dependent));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  void cepResolves() {
    when(
      () => lookupCep(any()),
    ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(fakeCepLookup()));
  }

  Future<void> typeCep(WidgetTester tester, String cep) async {
    await tester.enterText(fieldLabeled('CEP'), cep);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  Future<void> chooseGender(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButton<Gender?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  void createSucceeds() {
    when(() => createDependent(any())).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
    );
  }

  group('structure', () {
    testWidgets('a new dependent starts with an empty form', (tester) async {
      await openForm(tester);

      expect(find.text('Novo dependente'), findsOneWidget);
      expect(textOf(tester, 'Data de nascimento'), isEmpty);
      expect(find.byTooltip('Limpar data'), findsNothing);
      expect(find.byType(VanepAddressCard), findsOneWidget);
      expect(find.text('Nenhum endereço informado.'), findsOneWidget);
      expect(find.text('Cadastrar endereço'), findsOneWidget);
    });

    testWidgets('the address is a card, not the inline form', (tester) async {
      await openForm(tester);

      expect(find.byType(VanepPostalAddressForm), findsNothing);
      expect(find.byType(VanepPlaceAutocompleteField), findsNothing);
    });

    testWidgets('uses the identity chrome', (tester) async {
      await openForm(tester);

      expect(find.byType(VanepAppBar), findsOneWidget);
      expect(find.byType(VanepPageHeader), findsOneWidget);
      expect(find.byType(VanepBottomBar), findsOneWidget);
    });

    testWidgets('the save button sits in the bottom bar', (tester) async {
      await openForm(tester);

      expect(
        find.descendant(
          of: find.byType(VanepBottomBar),
          matching: find.text('Salvar'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('editing prefills the fields and summarizes the address', (
      tester,
    ) async {
      await openForm(tester, dependent: helenaWithAddress);

      expect(find.text('Editar dependente'), findsOneWidget);
      expect(find.text('Helena Souza'), findsOneWidget);
      expect(find.text('QNL 5 Conjunto A, 12, Casa 2'), findsOneWidget);
      expect(find.text('Taguatinga · Brasília/DF · 72120-120'), findsOneWidget);
      expect(find.byTooltip('Limpar data'), findsOneWidget);
      expect(find.text('Cadastrar endereço'), findsNothing);
    });
  });

  group('gender', () {
    testWidgets('is the shared select with Prefiro não informar', (
      tester,
    ) async {
      await openForm(tester);

      expect(find.byType(VanepGenderSelect), findsOneWidget);
      expect(find.text('Prefiro não informar'), findsOneWidget);
      expect(find.text('Não informar'), findsNothing);
    });

    testWidgets('a create without a gender leaves it out', (tester) async {
      createSucceeds();
      await openForm(tester);

      await tester.enterText(fieldLabeled('Nome'), 'Helena Souza');
      await tapSave(tester);

      final draft =
          verify(() => createDependent(captureAny())).captured.single
              as DependentDraft;
      expect(draft.gender, isNull);
    });

    testWidgets('choosing Prefiro não informar clears a saved gender', (
      tester,
    ) async {
      when(
        () => updateDependent(
          snapshot: any(named: 'snapshot'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
      );
      await openForm(tester, dependent: helenaWithAddress);

      await chooseGender(tester, 'Prefiro não informar');
      await tapSave(tester);

      final draft =
          verify(
                () => updateDependent(
                  snapshot: helenaWithAddress,
                  draft: captureAny(named: 'draft'),
                ),
              ).captured.single
              as DependentDraft;
      expect(draft.gender, isNull);
    });
  });

  group('address', () {
    Future<void> openAddressPage(WidgetTester tester) async {
      await tester.tap(find.text('Cadastrar endereço'));
      await tester.pumpAndSettle();
    }

    Future<void> confirmAddress(WidgetTester tester) async {
      await tester.tap(find.text('Confirmar endereço'));
      await tester.pumpAndSettle();
    }

    Future<void> chooseMenuAction(WidgetTester tester, String label) async {
      await tester.tap(find.byType(PopupMenuButton<VanepAddressCardAction>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    testWidgets('registering opens the address page and returns the summary', (
      tester,
    ) async {
      cepResolves();
      await openForm(tester);

      await openAddressPage(tester);
      expect(find.byType(DependentAddressFormPage), findsOneWidget);
      await typeCep(tester, '72120120');
      await confirmAddress(tester);

      expect(find.byType(DependentAddressFormPage), findsNothing);
      expect(find.byType(DependentFormView), findsOneWidget);
      expect(find.text('QND 12'), findsOneWidget);
      expect(find.text('Taguatinga · Brasília/DF · 72120-120'), findsOneWidget);
      expect(find.text('Cadastrar endereço'), findsNothing);
    });

    testWidgets('a saved dependent with an address closes the form', (
      tester,
    ) async {
      createSucceeds();
      cepResolves();
      await openForm(tester);

      await tester.enterText(fieldLabeled('Nome'), 'Helena Souza');
      await openAddressPage(tester);
      await typeCep(tester, '72120120');
      await tester.enterText(fieldLabeled('Número'), '340');
      await tester.enterText(fieldLabeled('Complemento'), 'Bloco B');
      await confirmAddress(tester);
      await tapSave(tester);

      final draft =
          verify(() => createDependent(captureAny())).captured.single
              as DependentDraft;
      expect(draft.name, 'Helena Souza');
      expect(draft.address.cityToken, 'city-brasilia');
      expect(draft.address.zipCode, '72120120');
      expect(draft.address.street, 'QND 12');
      expect(draft.address.number, '340');
      expect(draft.address.complement, 'Bloco B');
      expect(find.byType(DependentFormView), findsNothing);
      expect(find.text('abrir'), findsOneWidget);
    });

    testWidgets('editing changes only the number and resends the address', (
      tester,
    ) async {
      when(
        () => updateDependent(
          snapshot: any(named: 'snapshot'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
      );
      await openForm(tester, dependent: helenaWithAddress);

      await chooseMenuAction(tester, 'Editar endereço');
      expect(find.text('Editar endereço'), findsWidgets);
      await tester.enterText(fieldLabeled('Número'), '99');
      await confirmAddress(tester);
      await tapSave(tester);

      final draft =
          verify(
                () => updateDependent(
                  snapshot: helenaWithAddress,
                  draft: captureAny(named: 'draft'),
                ),
              ).captured.single
              as DependentDraft;
      expect(draft.address.number, '99');
      expect(draft.address.cityToken, 'city-brasilia');
    });

    testWidgets('clearing from the menu brings the empty card back', (
      tester,
    ) async {
      await openForm(tester, dependent: helenaWithAddress);

      await chooseMenuAction(tester, 'Limpar endereço');

      expect(find.text('Nenhum endereço informado.'), findsOneWidget);
      expect(find.text('Cadastrar endereço'), findsOneWidget);
      expect(find.text('QNL 5 Conjunto A, 12, Casa 2'), findsNothing);
    });

    testWidgets('a cleared address is sent as removed', (tester) async {
      when(
        () => updateDependent(
          snapshot: any(named: 'snapshot'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer(
        (_) async => const Ok<DependentFailure, Dependent>(testHelenaDependent),
      );
      await openForm(tester, dependent: helenaWithAddress);

      await chooseMenuAction(tester, 'Limpar endereço');
      await tapSave(tester);

      final draft =
          verify(
                () => updateDependent(
                  snapshot: helenaWithAddress,
                  draft: captureAny(named: 'draft'),
                ),
              ).captured.single
              as DependentDraft;
      expect(draft.address.isBlank, isTrue);
    });

    testWidgets('a city the backend rejects is flagged on the card', (
      tester,
    ) async {
      when(() => createDependent(any())).thenAnswer(
        (_) async => const Err<DependentFailure, Dependent>(
          DependentCityNotFoundFailure(),
        ),
      );
      cepResolves();
      await openForm(tester);

      await tester.enterText(fieldLabeled('Nome'), 'Helena Souza');
      await openAddressPage(tester);
      await typeCep(tester, '72120120');
      await confirmAddress(tester);
      await tapSave(tester);

      const message =
          'Não encontramos essa cidade. Escolha o município novamente.';
      expect(find.text(message), findsOneWidget);
      expect(find.byType(DependentFormView), findsOneWidget);
      expect(find.text('Helena Souza'), findsOneWidget);
    });

    testWidgets('editing after a rejected city opens the manual fallback', (
      tester,
    ) async {
      when(() => createDependent(any())).thenAnswer(
        (_) async => const Err<DependentFailure, Dependent>(
          DependentCityNotFoundFailure(),
        ),
      );
      cepResolves();
      await openForm(tester);

      await tester.enterText(fieldLabeled('Nome'), 'Helena Souza');
      await openAddressPage(tester);
      await typeCep(tester, '72120120');
      await confirmAddress(tester);
      await tapSave(tester);
      await chooseMenuAction(tester, 'Editar endereço');

      expect(find.byType(DependentAddressFormPage), findsOneWidget);
      expect(find.text('Município'), findsOneWidget);
      expect(find.byType(VanepCepAddressCard), findsNothing);
      expect(
        find.text(
          'Não encontramos essa cidade. Escolha o município novamente.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a generic validation failure shows the localized copy', (
      tester,
    ) async {
      when(() => createDependent(any())).thenAnswer(
        (_) async => const Err<DependentFailure, Dependent>(
          DependentValidationFailure(),
        ),
      );
      await openForm(tester);

      await tester.enterText(fieldLabeled('Nome'), 'Helena Souza');
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text(
          'Não foi possível salvar. Revise os dados e tente novamente.',
        ),
        findsOneWidget,
      );
      expect(find.byType(DependentFormView), findsOneWidget);
    });
  });

  group('name and birth date', () {
    testWidgets('saving without a name shows the local error', (tester) async {
      await openForm(tester);

      await tester.tap(find.text('Salvar'));
      await tester.pump();

      expect(find.text('Informe o nome do dependente.'), findsOneWidget);
      verifyNever(() => createDependent(any()));
    });

    testWidgets('clearing the birth date removes the clear button', (
      tester,
    ) async {
      await openForm(tester, dependent: helenaWithAddress);

      await tester.tap(find.byTooltip('Limpar data'));
      await tester.pump();

      expect(find.byTooltip('Limpar data'), findsNothing);
      expect(textOf(tester, 'Data de nascimento'), isEmpty);
    });

    testWidgets('picking a birth date from the calendar fills it', (
      tester,
    ) async {
      await openForm(tester);

      await tester.tap(find.text('Selecionar data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'Data de nascimento'), isNotEmpty);
      expect(find.byTooltip('Limpar data'), findsOneWidget);
    });

    testWidgets('dismissing the calendar keeps the date empty', (tester) async {
      await openForm(tester);

      await tester.tap(find.text('Selecionar data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'Data de nascimento'), isEmpty);
    });
  });

  test('opening the picker on 2015-03-22 keeps 22 March, not 21', () {
    final today = DateTime(2026, 9, 17);
    final initial = initialBirthDatePickerDay('2015-03-22', today);

    expect(initial.year, 2015);
    expect(initial.month, 3);
    expect(initial.day, 22);
  });

  test('a missing birth date opens the picker on today', () {
    final today = DateTime(2026, 9, 17);

    expect(initialBirthDatePickerDay(null, today), today);
  });
}
