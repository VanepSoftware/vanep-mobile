import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/ui/vanep_city_picker_sheet.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';
import 'package:vanep_mobile/core/ui/vanep_cep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_address_form_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../../ibge_locations/ibge_locations_fixture.dart';
import '../personal_address_fixture.dart';
import 'auth_presentation_mocks.dart';
import 'personal_data_fixture.dart';

Widget formHarness(PersonalDataCubit cubit) {
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
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider<PersonalDataCubit>.value(
                value: cubit,
                child: const PersonalAddressFormPage(),
              ),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    ),
  );
}

Future<void> openForm(
  WidgetTester tester,
  PersonalDataCubit cubit, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(formHarness(cubit));
  await tester.tap(find.text('abrir'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Finder labelled(String label) => find.byWidgetPredicate(
  (widget) => widget is VanepTextField && widget.label == label,
);

TextField fieldLabelled(WidgetTester tester, String label) {
  return tester.widget<TextField>(
    find.descendant(of: labelled(label), matching: find.byType(TextField)),
  );
}

void main() {
  late MockPersonalDataCubit cubit;

  setUpAll(() => registerFallbackValue(fakeBrazilianCity()));

  void stateIs(PersonalDataState state) =>
      when(() => cubit.state).thenReturn(state);

  setUp(() {
    cubit = MockPersonalDataCubit();
    stateIs(readyState());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(cubit.close).thenAnswer((_) async {});
    when(cubit.clearFeedback).thenReturn(null);
    when(cubit.refreshStates).thenAnswer((_) async {});
    when(
      () => cubit.refreshCities(any(), search: any(named: 'search')),
    ).thenAnswer((_) async {});
    when(() => cubit.updateZipCode(any())).thenReturn(null);
    when(() => cubit.updateStreet(any())).thenReturn(null);
    when(() => cubit.updateNumber(any())).thenReturn(null);
    when(() => cubit.updateComplement(any())).thenReturn(null);
    when(() => cubit.updateNeighborhood(any())).thenReturn(null);
    when(() => cubit.selectUf(any())).thenAnswer((_) async {});
    when(() => cubit.selectCity(any())).thenReturn(null);
    when(cubit.save).thenAnswer((_) async {});
  });

  testWidgets('uses the new chrome and has no Places autocomplete', (
    tester,
  ) async {
    await openForm(tester, cubit);

    expect(find.byType(VanepAppBar), findsOneWidget);
    expect(find.byType(VanepBottomBar), findsOneWidget);
    expect(find.byType(VanepPlaceAutocompleteField), findsNothing);
  });

  group('header', () {
    testWidgets('shows a title and a subtitle in the body for a new address', (
      tester,
    ) async {
      await openForm(tester, cubit);

      final header = tester.widget<VanepPageHeader>(
        find.byType(VanepPageHeader),
      );
      expect(header.title, 'Cadastrar endereço');
      expect(
        header.subtitle,
        'Informe seu CEP e complete os dados do endereço.',
      );
      expect(find.text(header.title), findsOneWidget);
      expect(find.text(header.subtitle), findsOneWidget);
    });

    testWidgets('shows the edit title when a house is saved', (tester) async {
      stateIs(readyState(address: fakePersonalAddress()));

      await openForm(tester, cubit);

      expect(
        tester.widget<VanepPageHeader>(find.byType(VanepPageHeader)).title,
        'Editar endereço',
      );
      expect(find.text('Editar endereço'), findsOneWidget);
    });

    testWidgets('the app bar carries no title of its own', (tester) async {
      await openForm(tester, cubit);

      expect(
        tester.widget<VanepAppBar>(find.byType(VanepAppBar)).title,
        isNull,
      );
    });

    testWidgets('the header scrolls with the form, above the CEP', (
      tester,
    ) async {
      await openForm(tester, cubit);

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(VanepPageHeader),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.byType(VanepPageHeader)).dy,
        lessThan(tester.getTopLeft(labelled('CEP')).dy),
      );
    });
  });

  testWidgets(
    'a new address starts with the CEP, street, number and complement',
    (tester) async {
      await openForm(tester, cubit);

      for (final label in ['CEP', 'Rua', 'Número', 'Complemento']) {
        expect(labelled(label), findsOneWidget, reason: label);
      }
      for (final label in ['Bairro', 'Município']) {
        expect(labelled(label), findsNothing, reason: label);
      }
    },
  );

  testWidgets('the manual fallback shows every field of the postal form', (
    tester,
  ) async {
    stateIs(readyState(addressDraft: fakeManualDraft()));

    await openForm(tester, cubit);

    for (final label in [
      'CEP',
      'Rua',
      'Número',
      'Complemento',
      'Bairro',
      'Município',
    ]) {
      expect(labelled(label), findsOneWidget, reason: label);
    }
    expect(find.text('*'), findsNWidgets(4));
  });

  testWidgets('typing on the zip field forwards the masked text', (
    tester,
  ) async {
    await openForm(tester, cubit);

    await tester.enterText(find.byType(TextField).first, '70040010');

    verify(() => cubit.updateZipCode('70040-010')).called(1);
  });

  testWidgets('hydrates every field from the saved house', (tester) async {
    stateIs(readyState(address: fakePersonalAddress()));

    await openForm(tester, cubit);

    expect(find.text('72120-120'), findsOneWidget);
    expect(find.text('Taguatinga, Brasília – DF'), findsOneWidget);
    expect(find.text('QND 12'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Casa 2'), findsOneWidget);
  });

  testWidgets('a saved neighborhood is not editable when editing', (
    tester,
  ) async {
    stateIs(readyState(address: fakePersonalAddress()));

    await openForm(tester, cubit);

    expect(labelled('Bairro'), findsNothing);
  });

  testWidgets('a saved house without neighborhood keeps the field editable', (
    tester,
  ) async {
    stateIs(readyState(address: fakePersonalAddress(neighborhood: null)));

    await openForm(tester, cubit);

    expect(find.text('Brasília – DF'), findsOneWidget);
    expect(fieldLabelled(tester, 'Bairro').enabled, isTrue);
  });

  group('saving', () {
    testWidgets('an empty form blocks save and shows the required errors', (
      tester,
    ) async {
      await openForm(tester, cubit);

      await tester.tap(find.byType(VanepPrimaryButton));
      await tester.pump();

      expect(find.text('Campo obrigatório.'), findsNWidgets(2));
      verifyNever(cubit.save);
    });

    testWidgets('a savable draft asks the cubit to save', (tester) async {
      stateIs(readyState(addressDraft: fakeCompleteDraft()));

      await openForm(tester, cubit);
      await tester.tap(find.byType(VanepPrimaryButton));
      await tester.pump();

      verify(cubit.save).called(1);
    });

    testWidgets('a CEP that does not exist disables the save button', (
      tester,
    ) async {
      stateIs(
        readyState(
          addressDraft: fakeCompleteDraft().copyWith(isZipCodeUnknown: true),
        ).copyWith(cepFailure: CepFailure.notFound),
      );

      await openForm(tester, cubit);

      final save = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(save.onPressed, isNull);
      verifyNever(cubit.save);
    });

    testWidgets('shows the saving state on the button', (tester) async {
      stateIs(
        readyState(
          addressDraft: fakeCompleteDraft(),
        ).copyWith(status: PersonalDataStatus.saving),
      );

      await openForm(tester, cubit, settle: false);

      final save = tester.widget<VanepPrimaryButton>(
        find.byType(VanepPrimaryButton),
      );
      expect(save.isLoading, isTrue);
    });
  });

  group('CEP lookup', () {
    testWidgets('shows the failure message on the zip field', (tester) async {
      stateIs(
        readyState(
          addressDraft: const PostalAddressDraft()
              .withZipCode('00000000')
              .withCepUnknown(),
        ).copyWith(cepFailure: CepFailure.notFound),
      );

      await openForm(tester, cubit);

      expect(find.text('CEP não encontrado.'), findsOneWidget);
    });

    testWidgets(
      'a resolved CEP shows the summary card, not UF and municipality',
      (tester) async {
        final draft = const PostalAddressDraft()
            .withZipCode('72120120')
            .withCepLookup(
              cityToken: 'city-brasilia',
              cityName: 'Brasília',
              uf: 'DF',
              street: 'QND 12',
              neighborhood: 'Taguatinga',
            );
        stateIs(readyState(addressDraft: draft));

        await openForm(tester, cubit);

        expect(find.byType(VanepCepAddressCard), findsOneWidget);
        expect(find.text('Taguatinga, Brasília – DF'), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsNothing);
        expect(labelled('Município'), findsNothing);
        expect(labelled('Bairro'), findsNothing);
        verifyNever(cubit.refreshStates);
      },
    );

    testWidgets('keeps the bairro editable when the lookup omitted it', (
      tester,
    ) async {
      final draft = const PostalAddressDraft()
          .withZipCode('72120120')
          .withCepLookup(
            cityToken: 'city-brasilia',
            cityName: 'Brasília',
            uf: 'DF',
            street: 'QND 12',
          );
      stateIs(readyState(addressDraft: draft));

      await openForm(tester, cubit);

      expect(draft.isNeighborhoodLocked, isFalse);
      expect(fieldLabelled(tester, 'Bairro').enabled, isTrue);
    });

    testWidgets('shows the spinner on the CEP while the lookup runs', (
      tester,
    ) async {
      stateIs(
        readyState(
          addressDraft: const PostalAddressDraft().withZipCode('70040010'),
        ).copyWith(isLookingUpCep: true),
      );

      await openForm(tester, cubit, settle: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(labelled('Município'), findsNothing);
    });

    testWidgets('a failed lookup unlocks UF and municipality', (tester) async {
      stateIs(
        readyState(
          addressDraft: const PostalAddressDraft()
              .withZipCode('70040010')
              .withCepUnavailable()
              .withUf('DF'),
        ).copyWith(cepFailure: CepFailure.rateLimited),
      );

      await openForm(tester, cubit);

      final dropdown = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      expect(dropdown.onChanged, isNotNull);
      expect(fieldLabelled(tester, 'Município').enabled, isTrue);
      expect(
        find.text('Muitas consultas de CEP. Aguarde um momento.'),
        findsOneWidget,
      );
    });
  });

  group('states and cities', () {
    testWidgets('opening the form does not load the states by itself', (
      tester,
    ) async {
      await openForm(tester, cubit);

      verifyNever(cubit.refreshStates);
    });

    testWidgets('the UF list carries the loaded states', (tester) async {
      stateIs(
        readyState(
          addressDraft: fakeManualDraft(),
        ).copyWith(catalogStates: const [fakeDfState, fakeGoState]),
      );

      await openForm(tester, cubit);
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('DF'), findsWidgets);
      expect(find.text('GO'), findsWidgets);
    });

    testWidgets('choosing a UF asks the cubit', (tester) async {
      stateIs(
        readyState(
          addressDraft: fakeManualDraft(),
        ).copyWith(catalogStates: const [fakeDfState, fakeGoState]),
      );

      await openForm(tester, cubit);
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GO').last);
      await tester.pumpAndSettle();

      verify(() => cubit.selectUf('GO')).called(1);
    });

    testWidgets('the municipality is closed until a UF is chosen', (
      tester,
    ) async {
      stateIs(readyState(addressDraft: fakeManualDraft()));

      await openForm(tester, cubit);

      expect(fieldLabelled(tester, 'Município').enabled, isFalse);
      expect(find.text('Selecione o estado primeiro'), findsOneWidget);
    });

    testWidgets('opens the searchable picker once a UF is set', (tester) async {
      stateIs(
        readyState(
          addressDraft: fakeManualDraft().withUf('DF'),
        ).copyWith(catalogCities: [fakeBrazilianCity()]),
      );

      await openForm(tester, cubit);
      await tester.tap(find.text('Selecione a cidade'));
      await tester.pumpAndSettle();

      verify(() => cubit.refreshCities('DF')).called(1);
      expect(find.byType(VanepCityPickerSheet), findsOneWidget);
      expect(find.text('Selecionar cidade'), findsOneWidget);
      expect(find.text('Brasília'), findsOneWidget);
    });

    testWidgets('choosing a city asks the cubit and closes the sheet', (
      tester,
    ) async {
      stateIs(
        readyState(
          addressDraft: fakeManualDraft().withUf('DF'),
        ).copyWith(catalogCities: [fakeBrazilianCity()]),
      );

      await openForm(tester, cubit);
      await tester.tap(find.text('Selecione a cidade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Brasília'));
      await tester.pumpAndSettle();

      verify(() => cubit.selectCity(fakeBrazilianCity())).called(1);
      expect(find.byType(VanepCityPickerSheet), findsNothing);
    });

    testWidgets('a search inside the sheet asks the cubit with the same UF', (
      tester,
    ) async {
      stateIs(
        readyState(
          addressDraft: fakeManualDraft().withUf('DF'),
        ).copyWith(catalogCities: [fakeBrazilianCity()]),
      );

      await openForm(tester, cubit);
      await tester.tap(find.text('Selecione a cidade'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(VanepCityPickerSheet),
          matching: find.byType(TextField),
        ),
        'bras',
      );

      verify(() => cubit.refreshCities('DF', search: 'bras')).called(1);
    });

    testWidgets('a catalog failure replaces the list inside the sheet', (
      tester,
    ) async {
      stateIs(
        readyState(
          addressDraft: fakeManualDraft().withUf('DF'),
        ).copyWith(catalogFailure: IbgeLocationsFailure.ufNotFound),
      );

      await openForm(tester, cubit);
      await tester.tap(find.text('Selecione a cidade'));
      await tester.pumpAndSettle();

      expect(find.text('UF não encontrada.'), findsOneWidget);
    });
  });

  group('feedback', () {
    testWidgets('shows the mapped error when saving fails', (tester) async {
      final initial = readyState(addressDraft: fakeCompleteDraft());
      whenListen(
        cubit,
        Stream.value(
          initial.copyWith(
            feedback: const PersonalDataAddressSaveFailureFeedback(
              PersonalAddressFailure.cityNotFound,
            ),
          ),
        ),
        initialState: initial,
      );

      await openForm(tester, cubit);
      await tester.pump();

      expect(find.text('Cidade não encontrada no catálogo.'), findsOneWidget);
      verify(cubit.clearFeedback).called(1);
    });

    testWidgets('pops the page once the address is saved', (tester) async {
      final initial = readyState(addressDraft: fakeCompleteDraft());
      whenListen(
        cubit,
        Stream.value(
          initial.copyWith(feedback: const PersonalDataSaveSuccessFeedback()),
        ),
        initialState: initial,
      );

      await openForm(tester, cubit);
      await tester.pumpAndSettle();

      expect(find.byType(PersonalAddressFormPage), findsNothing);
      expect(find.text('abrir'), findsOneWidget);
    });
  });
}
