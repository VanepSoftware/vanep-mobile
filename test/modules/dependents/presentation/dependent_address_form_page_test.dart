import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_cep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/ui/vanep_postal_address_form.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/pages/dependent_address_form_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';

import '../../ibge_locations/ibge_locations_fixture.dart';
import '../../ibge_locations/ibge_locations_mocks.dart';
import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

const helenaWithAddress = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  address: TestDependentAddress(complement: 'Casa 2'),
);

Widget harness(DependentFormCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<DependentFormCubit>.value(
      value: cubit,
      child: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => openDependentAddressFormPage(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
    lookupCep = MockLookupCep();
    listStates = MockListStates();
    listCities = MockListCities();
    when(() => listStates()).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: const [fakeDfState])),
    );
    when(() => listCities(uf: any(named: 'uf'))).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: [fakeBrazilianCity()])),
    );
  });

  DependentFormCubit buildCubit({Dependent? dependent}) {
    final cubit = DependentFormCubit(
      createDependent: MockCreateDependent(),
      updateDependent: MockUpdateDependent(),
      lookupCep: lookupCep,
      listStates: listStates,
      listCities: listCities,
      cepLookupDebounce: Duration.zero,
      dependent: dependent,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Finder fieldLabeled(String label) => find.descendant(
    of: find.widgetWithText(VanepTextField, label),
    matching: find.byType(TextField),
  );

  Future<void> openPage(WidgetTester tester, DependentFormCubit cubit) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  void cepResolves() {
    when(
      () => lookupCep(any()),
    ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(fakeCepLookup()));
  }

  void cepFails(CepFailure failure) {
    when(
      () => lookupCep(any()),
    ).thenAnswer((_) async => Err<CepFailure, CepLookup>(failure));
  }

  Future<void> typeCep(WidgetTester tester, String cep) async {
    await tester.enterText(fieldLabeled('CEP'), cep);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  Future<void> tapConfirm(WidgetTester tester) async {
    await tester.tap(find.text('Confirmar endereço'));
    await tester.pumpAndSettle();
  }

  group('structure', () {
    testWidgets('a new address is titled Cadastrar endereço', (tester) async {
      await openPage(tester, buildCubit());

      expect(find.text('Cadastrar endereço'), findsOneWidget);
      expect(find.byType(VanepAppBar), findsOneWidget);
      expect(find.byType(VanepPageHeader), findsOneWidget);
      expect(find.byType(VanepPostalAddressForm), findsOneWidget);
      expect(find.byType(VanepPlaceAutocompleteField), findsNothing);
    });

    testWidgets('an existing address is titled Editar endereço', (
      tester,
    ) async {
      await openPage(tester, buildCubit(dependent: helenaWithAddress));

      expect(find.text('Editar endereço'), findsOneWidget);
      expect(find.byType(VanepCepAddressCard), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('the confirm button sits in the bottom bar', (tester) async {
      await openPage(tester, buildCubit());

      expect(
        find.descendant(
          of: find.byType(VanepBottomBar),
          matching: find.text('Confirmar endereço'),
        ),
        findsOneWidget,
      );
    });
  });

  group('confirming', () {
    testWidgets('a resolved cep is kept and the page closes', (tester) async {
      cepResolves();
      final cubit = buildCubit();
      await openPage(tester, cubit);

      await typeCep(tester, '72120120');
      expect(find.byType(VanepCepAddressCard), findsOneWidget);
      await tapConfirm(tester);

      expect(find.byType(DependentAddressFormPage), findsNothing);
      expect(cubit.state.draft.address.cityToken, 'city-brasilia');
      expect(cubit.state.draft.address.street, 'QND 12');
    });

    testWidgets('a partial address shows what is missing and stays open', (
      tester,
    ) async {
      final cubit = buildCubit();
      await openPage(tester, cubit);

      await tester.enterText(fieldLabeled('Rua'), 'Rua Sete');
      await tapConfirm(tester);

      expect(find.text('Campo obrigatório.'), findsOneWidget);
      expect(find.byType(DependentAddressFormPage), findsOneWidget);
    });

    testWidgets('a cep that does not exist disables the confirm button', (
      tester,
    ) async {
      cepFails(CepFailure.notFound);
      await openPage(tester, buildCubit());

      await typeCep(tester, '99999999');

      expect(find.text('CEP não encontrado.'), findsOneWidget);
      final button = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('a pending lookup disables the confirm button', (tester) async {
      when(() => lookupCep(any())).thenAnswer(
        (_) => Future<Result<CepFailure, CepLookup>>.delayed(
          const Duration(seconds: 5),
          () => Ok<CepFailure, CepLookup>(fakeCepLookup()),
        ),
      );
      await openPage(tester, buildCubit());

      await tester.enterText(fieldLabeled('CEP'), '72120120');
      await tester.pump();

      final button = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(button.onPressed, isNull);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('leaving without confirming', () {
    testWidgets('discards a new address', (tester) async {
      final cubit = buildCubit();
      await openPage(tester, cubit);

      await tester.enterText(fieldLabeled('Rua'), 'Rua Sete');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(DependentAddressFormPage), findsNothing);
      expect(cubit.state.draft.address.isBlank, isTrue);
    });

    testWidgets('restores the saved address after an edit', (tester) async {
      final cubit = buildCubit(dependent: helenaWithAddress);
      await openPage(tester, cubit);

      await tester.enterText(fieldLabeled('Número'), '99');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(cubit.state.draft.address.number, '12');
      expect(cubit.state.draft.address.isCityLocked, isTrue);
    });

    testWidgets('drops a lookup that was still pending', (tester) async {
      cepResolves();
      final cubit = buildCubit();
      await openPage(tester, cubit);

      await tester.enterText(fieldLabeled('CEP'), '72120120');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(cubit.state.draft.address.isBlank, isTrue);
      expect(cubit.state.isLookingUpCep, isFalse);
    });

    testWidgets('keeps the confirmed address when leaving afterwards', (
      tester,
    ) async {
      cepResolves();
      final cubit = buildCubit();
      await openPage(tester, cubit);
      await typeCep(tester, '72120120');
      await tapConfirm(tester);

      expect(cubit.state.draft.address.cityToken, 'city-brasilia');
    });
  });

  group('manual fallback', () {
    testWidgets('a city outside the catalog opens the picker fields', (
      tester,
    ) async {
      cepFails(CepFailure.cityNotInCatalog);
      await openPage(tester, buildCubit());

      await typeCep(tester, '72120120');
      await tester.pumpAndSettle();

      expect(
        find.text('Município deste CEP não está no catálogo.'),
        findsOneWidget,
      );
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Município'), findsOneWidget);
    });

    testWidgets('picks the city in the sheet and confirms', (tester) async {
      cepFails(CepFailure.cityNotInCatalog);
      final cubit = buildCubit();
      await openPage(tester, cubit);

      await typeCep(tester, '72120120');
      await tester.pumpAndSettle();
      await tester.enterText(fieldLabeled('Rua'), 'QND 12');
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DF').last);
      await tester.pumpAndSettle();
      await tester.tap(fieldLabeled('Município'));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar cidade'), findsOneWidget);
      verify(() => listCities(uf: 'DF')).called(greaterThanOrEqualTo(1));

      await tester.tap(find.text('Brasília'));
      await tester.pumpAndSettle();
      await tapConfirm(tester);

      expect(find.byType(DependentAddressFormPage), findsNothing);
      expect(cubit.state.draft.address.cityToken, 'city-brasilia');
    });
  });
}
