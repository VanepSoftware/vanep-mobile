import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_cep_address_card.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/personal_address_form_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';

import '../../ibge_locations/ibge_locations_fixture.dart';
import '../../ibge_locations/ibge_locations_mocks.dart';
import '../auth_fixtures.dart';
import '../auth_mocks.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockRefreshUserProfile refreshUserProfile;
  late MockFindMyPersonalAddress findMyPersonalAddress;
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;
  late PersonalDataCubit cubit;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    refreshUserProfile = MockRefreshUserProfile();
    findMyPersonalAddress = MockFindMyPersonalAddress();
    lookupCep = MockLookupCep();
    listStates = MockListStates();
    listCities = MockListCities();
    when(refreshUserProfile.call).thenAnswer(
      (_) async => const Ok<ProfileEditFailure, UserProfile>(FakeUserProfile()),
    );
    when(findMyPersonalAddress.call).thenAnswer(
      (_) async => const Ok<PersonalAddressFailure, PersonalAddress?>(null),
    );
    when(() => listStates()).thenAnswer(
      (_) async => Ok(
        fakeIbgeLocationsPage(
          items: const <BrazilianState>[fakeDfState, fakeGoState],
        ),
      ),
    );
    when(() => listCities(uf: any(named: 'uf'))).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: <BrazilianCity>[])),
    );
    cubit = PersonalDataCubit(
      refreshUserProfile: refreshUserProfile,
      patchUserProfile: MockPatchUserProfile(),
      requestEmailChange: MockRequestEmailChange(),
      findMyPersonalAddress: findMyPersonalAddress,
      upsertMyPersonalAddress: MockUpsertMyPersonalAddress(),
      deleteMyPersonalAddress: MockDeleteMyPersonalAddress(),
      lookupCep: lookupCep,
      listStates: listStates,
      listCities: listCities,
      syncProfile: (_) {},
      cepLookupDebounce: const Duration(milliseconds: 400),
    );
  });

  tearDown(() => cubit.close());

  Future<void> openPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cubit.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: VanepTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider<PersonalDataCubit>.value(
          value: cubit,
          child: const PersonalAddressFormPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder labelled(String label) => find.byWidgetPredicate(
    (widget) => widget is VanepTextField && widget.label == label,
  );

  Future<void> typeCep(WidgetTester tester, String digits) async {
    await tester.enterText(find.byType(TextField).first, digits);
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
  }

  testWidgets('a CEP that resolves shows the summary card with the UF', (
    tester,
  ) async {
    when(() => lookupCep('72120120')).thenAnswer(
      (_) async => Ok<CepFailure, CepLookup>(
        fakeCepLookup(uf: 'GO', cityName: 'Goiânia', neighborhood: null),
      ),
    );

    await openPage(tester);
    await typeCep(tester, '72120120');

    verify(() => lookupCep('72120120')).called(1);
    expect(cubit.state.addressDraft.uf, 'GO');
    expect(find.byType(VanepCepAddressCard), findsOneWidget);
    expect(find.text('Goiânia – GO'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(labelled('Município'), findsNothing);
    expect(labelled('Rua'), findsOneWidget);
  });

  testWidgets('the CEP shows a spinner from the eighth digit to the answer', (
    tester,
  ) async {
    final answer = Completer<Result<CepFailure, CepLookup>>();
    when(() => lookupCep('72120120')).thenAnswer((_) => answer.future);

    await openPage(tester);
    await tester.enterText(find.byType(TextField).first, '72120120');
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(labelled('Município'), findsNothing);
    expect(find.byType(VanepCepAddressCard), findsNothing);

    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    answer.complete(Ok<CepFailure, CepLookup>(fakeCepLookup()));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(VanepCepAddressCard), findsOneWidget);
  });

  testWidgets('a lookup that fails opens the manual fields with the states', (
    tester,
  ) async {
    when(() => lookupCep('72120120')).thenAnswer(
      (_) async => const Err<CepFailure, CepLookup>(CepFailure.unavailable),
    );

    await openPage(tester);
    await typeCep(tester, '72120120');

    verify(() => listStates()).called(1);
    expect(find.byType(VanepCepAddressCard), findsNothing);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    for (final label in ['Município', 'Bairro', 'Rua']) {
      expect(labelled(label), findsOneWidget, reason: label);
    }
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a CEP that does not exist shows no location', (tester) async {
    when(() => lookupCep('00000000')).thenAnswer(
      (_) async => const Err<CepFailure, CepLookup>(CepFailure.notFound),
    );

    await openPage(tester);
    await typeCep(tester, '00000000');

    expect(find.text('CEP não encontrado.'), findsOneWidget);
    expect(labelled('Rua'), findsOneWidget);
    expect(labelled('Município'), findsNothing);
    expect(find.byType(DropdownButton<String>), findsNothing);
  });
}
