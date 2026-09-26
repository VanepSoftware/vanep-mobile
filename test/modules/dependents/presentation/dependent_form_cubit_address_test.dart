import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_form_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../../ibge_locations/ibge_locations_fixture.dart';
import '../../ibge_locations/ibge_locations_mocks.dart';
import '../dependents_fixtures.dart';
import '../dependents_mocks.dart';

const cepLookupTestWait = Duration(milliseconds: 20);

const helenaWithAddress = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  address: TestDependentAddress(complement: 'Casa 2'),
);

void main() {
  late MockCreateDependent createDependent;
  late MockUpdateDependent updateDependent;
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
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
  });

  DependentFormCubit buildCubit({Dependent? dependent}) => DependentFormCubit(
    createDependent: createDependent,
    updateDependent: updateDependent,
    lookupCep: lookupCep,
    listStates: listStates,
    listCities: listCities,
    cepLookupDebounce: Duration.zero,
    dependent: dependent,
  );

  void cepResolves([CepLookup? lookup]) {
    when(() => lookupCep(any())).thenAnswer(
      (_) async => Ok<CepFailure, CepLookup>(lookup ?? fakeCepLookup()),
    );
  }

  void cepFails(CepFailure failure) {
    when(
      () => lookupCep(any()),
    ).thenAnswer((_) async => Err<CepFailure, CepLookup>(failure));
  }

  void createSucceeds() {
    when(() => createDependent(any())).thenAnswer(
      (_) async => const Ok<DependentFailure, Dependent>(testMiguelDependent),
    );
  }

  Future<void> typeZip(DependentFormCubit cubit, String zip) async {
    cubit.updateZipCode(zip);
    await Future<void>.delayed(cepLookupTestWait);
  }

  group('cep lookup', () {
    blocTest<DependentFormCubit, DependentFormState>(
      'eight digits look the cep up with digits only',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '72120-120'),
      verify: (_) => verify(() => lookupCep('72120120')).called(1),
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'fewer than eight digits never look the cep up',
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '7212012'),
      verify: (cubit) {
        verifyNever(() => lookupCep(any()));
        expect(cubit.state.isLookingUpCep, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'the lookup is pending from the eighth digit until the answer',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) async {
        cubit.updateZipCode('72120120');
        expect(cubit.state.isLookingUpCep, isTrue);
        await Future<void>.delayed(cepLookupTestWait);
      },
      verify: (cubit) => expect(cubit.state.isLookingUpCep, isFalse),
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a 200 locks the city, replaces street and neighborhood and keeps number',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) async {
        cubit.updateNumber('340');
        cubit.updateComplement('Bloco B');
        cubit.updateStreet('Rua digitada');
        await typeZip(cubit, '72120120');
      },
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(address.cityToken, 'city-brasilia');
        expect(address.cityName, 'Brasília');
        expect(address.uf, 'DF');
        expect(address.isCityLocked, isTrue);
        expect(address.street, 'QND 12');
        expect(address.neighborhood, 'Taguatinga');
        expect(address.isNeighborhoodLocked, isTrue);
        expect(address.number, '340');
        expect(address.complement, 'Bloco B');
        expect(cubit.state.cepFailure, isNull);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a 200 without neighborhood leaves the field open',
      setUp: () => cepResolves(fakeCepLookup(neighborhood: null)),
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '72120120'),
      verify: (cubit) {
        expect(cubit.state.draft.address.neighborhood, isEmpty);
        expect(cubit.state.draft.address.isNeighborhoodLocked, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a city outside the catalog unlocks the picker and loads the states',
      setUp: () => cepFails(CepFailure.cityNotInCatalog),
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '72120120'),
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(cubit.state.cepFailure, CepFailure.cityNotInCatalog);
        expect(address.isCityLocked, isFalse);
        expect(address.cityToken, isEmpty);
        expect(address.zipCode, '72120120');
        expect(cubit.state.isAddressBlockingSave, isFalse);
        expect(cubit.state.catalogStates, const [fakeDfState]);
      },
    );

    for (final failure in [
      CepFailure.rateLimited,
      CepFailure.unavailable,
      CepFailure.network,
      CepFailure.unexpected,
    ]) {
      blocTest<DependentFormCubit, DependentFormState>(
        '$failure unlocks the picker without blocking the save',
        setUp: () => cepFails(failure),
        build: buildCubit,
        act: (cubit) => typeZip(cubit, '72120120'),
        verify: (cubit) {
          expect(cubit.state.cepFailure, failure);
          expect(cubit.state.draft.address.isCityLocked, isFalse);
          expect(cubit.state.isAddressBlockingSave, isFalse);
        },
      );
    }

    blocTest<DependentFormCubit, DependentFormState>(
      'a cep that does not exist blocks the save until the cep changes',
      setUp: () => cepFails(CepFailure.notFound),
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        await typeZip(cubit, '72120120');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.cepFailure, CepFailure.notFound);
        expect(cubit.state.draft.address.isZipCodeUnknown, isTrue);
        expect(cubit.state.isAddressBlockingSave, isTrue);
        verifyNever(() => createDependent(any()));
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'picking a state or city does not lift the nonexistent-cep block',
      setUp: () => cepFails(CepFailure.notFound),
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        await cubit.selectUf('DF');
        cubit.selectCity(fakeBrazilianCity());
      },
      verify: (cubit) {
        expect(cubit.state.cepFailure, CepFailure.notFound);
        expect(cubit.state.isAddressBlockingSave, isTrue);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'editing the cep after a nonexistent one lifts the block',
      setUp: () => cepFails(CepFailure.notFound),
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        cubit.updateZipCode('7212012');
      },
      verify: (cubit) {
        expect(cubit.state.cepFailure, isNull);
        expect(cubit.state.isAddressBlockingSave, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a stale lookup answer is ignored after the cep changes',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) async {
        cubit.updateZipCode('72120120');
        cubit.updateZipCode('7212012');
        await Future<void>.delayed(cepLookupTestWait);
      },
      verify: (cubit) {
        verifyNever(() => lookupCep(any()));
        expect(cubit.state.draft.address.cityToken, isEmpty);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'the save waits for a pending lookup',
      setUp: () {
        createSucceeds();
        when(
          () => lookupCep(any()),
        ).thenAnswer((_) => Completer<Result<CepFailure, CepLookup>>().future);
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        cubit.updateZipCode('72120120');
        await cubit.save();
      },
      verify: (cubit) {
        verifyNever(() => createDependent(any()));
        expect(cubit.state.isAddressBlockingSave, isTrue);
      },
    );
  });

  group('picker', () {
    blocTest<DependentFormCubit, DependentFormState>(
      'choosing a state clears the city and lists its cities',
      setUp: () => cepFails(CepFailure.cityNotInCatalog),
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        await cubit.selectUf('DF');
      },
      verify: (cubit) {
        expect(cubit.state.draft.address.uf, 'DF');
        expect(cubit.state.draft.address.cityToken, isEmpty);
        expect(cubit.state.catalogCities, hasLength(1));
        verify(() => listCities(uf: 'DF')).called(1);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a search always goes out with the state',
      setUp: () {
        cepFails(CepFailure.cityNotInCatalog);
        when(
          () => listCities(
            uf: any(named: 'uf'),
            search: any(named: 'search'),
          ),
        ).thenAnswer(
          (_) async => Ok(fakeIbgeLocationsPage(items: <BrazilianCity>[])),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        await cubit.selectUf('DF');
        await cubit.refreshCities('DF', search: 'bras');
      },
      verify: (_) =>
          verify(() => listCities(uf: 'DF', search: 'bras')).called(1),
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'no city is ever listed without a state',
      build: buildCubit,
      act: (cubit) => cubit.refreshCities(''),
      verify: (_) => verifyNever(() => listCities(uf: any(named: 'uf'))),
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'choosing a city stores its token and completes the address',
      setUp: () => cepFails(CepFailure.cityNotInCatalog),
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        await cubit.selectUf('DF');
        cubit.updateStreet('QND 12');
        cubit.selectCity(fakeBrazilianCity());
      },
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(address.cityToken, 'city-brasilia');
        expect(address.isComplete, isTrue);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a failing catalog is surfaced',
      setUp: () {
        when(
          () => listCities(uf: any(named: 'uf')),
        ).thenAnswer((_) async => const Err(IbgeLocationsFailure.network));
      },
      build: buildCubit,
      act: (cubit) => cubit.refreshCities('DF'),
      verify: (cubit) =>
          expect(cubit.state.catalogFailure, IbgeLocationsFailure.network),
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a locked city ignores the state and the city pickers',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        await cubit.selectUf('GO');
        cubit.selectCity(
          fakeBrazilianCity(token: 'city-goiania', name: 'Goiânia'),
        );
      },
      verify: (cubit) {
        expect(cubit.state.draft.address.cityToken, 'city-brasilia');
        expect(cubit.state.draft.address.uf, 'DF');
        verifyNever(() => listCities(uf: any(named: 'uf')));
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a locked neighborhood ignores typing',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        cubit.updateNeighborhood('Outro bairro');
      },
      verify: (cubit) =>
          expect(cubit.state.draft.address.neighborhood, 'Taguatinga'),
    );
  });

  group('hydration', () {
    blocTest<DependentFormCubit, DependentFormState>(
      'a saved address opens with the city and neighborhood locked',
      build: () => buildCubit(dependent: helenaWithAddress),
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(address.zipCode, '72120120');
        expect(address.isCityLocked, isTrue);
        expect(address.isNeighborhoodLocked, isTrue);
        expect(address.complement, 'Casa 2');
        verifyNever(() => lookupCep(any()));
      },
    );
  });

  group('clearAddress', () {
    blocTest<DependentFormCubit, DependentFormState>(
      'brings the draft back to blank',
      build: () => buildCubit(dependent: helenaWithAddress),
      act: (cubit) => cubit.clearAddress(),
      verify: (cubit) {
        expect(cubit.state.draft.address.isBlank, isTrue);
        expect(cubit.state.isLookingUpCep, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'drops a pending lookup and the previous cep failure',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) async {
        cubit.updateZipCode('72120120');
        cubit.clearAddress();
        await Future<void>.delayed(cepLookupTestWait);
      },
      verify: (cubit) {
        verifyNever(() => lookupCep(any()));
        expect(cubit.state.draft.address.isBlank, isTrue);
        expect(cubit.state.cepFailure, isNull);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a saved dependent that clears the address sends a blank draft',
      setUp: () {
        when(
          () => updateDependent(
            snapshot: any(named: 'snapshot'),
            draft: any(named: 'draft'),
          ),
        ).thenAnswer(
          (_) async =>
              const Ok<DependentFailure, Dependent>(testHelenaDependent),
        );
      },
      build: () => buildCubit(dependent: helenaWithAddress),
      act: (cubit) async {
        cubit.clearAddress();
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentFormStatus.saved);
        final draft =
            verify(
                  () => updateDependent(
                    snapshot: helenaWithAddress,
                    draft: captureAny(named: 'draft'),
                  ),
                ).captured.single
                as DependentDraft;
        expect(draft.address.isBlank, isTrue);
      },
    );
  });

  group('save', () {
    blocTest<DependentFormCubit, DependentFormState>(
      'a dependent saves without an address',
      setUp: createSucceeds,
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Miguel');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentFormStatus.saved);
        final draft =
            verify(() => createDependent(captureAny())).captured.single
                as DependentDraft;
        expect(draft.address.isBlank, isTrue);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a partial address blocks the save without a request',
      setUp: createSucceeds,
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        cubit.updateStreet('Rua Sete');
        await cubit.save();
      },
      verify: (cubit) {
        verifyNever(() => createDependent(any()));
        expect(cubit.state.showsAddressErrors, isTrue);
        expect(cubit.state.status, DependentFormStatus.editing);
        expect(
          cubit.state.draft.address.issues,
          contains(PostalAddressIssue.zipCodeInvalid),
        );
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'the address errors stay until the address is blank again',
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        cubit.updateStreet('Rua Sete');
        await cubit.save();
        cubit.updateStreet('');
      },
      verify: (cubit) {
        expect(cubit.state.showAddressIssues, isTrue);
        expect(cubit.state.showsAddressErrors, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a complete address reaches the use case',
      setUp: () {
        createSucceeds();
        cepResolves();
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        await typeZip(cubit, '72120120');
        cubit.updateNumber('10');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentFormStatus.saved);
        final draft =
            verify(() => createDependent(captureAny())).captured.single
                as DependentDraft;
        expect(draft.address.cityToken, 'city-brasilia');
        expect(draft.address.zipCode, '72120120');
        expect(draft.address.number, '10');
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a saved address the person never touched does not block other edits',
      setUp: () {
        when(
          () => updateDependent(
            snapshot: any(named: 'snapshot'),
            draft: any(named: 'draft'),
          ),
        ).thenAnswer(
          (_) async =>
              const Ok<DependentFailure, Dependent>(testHelenaDependent),
        );
      },
      build: () => buildCubit(
        dependent: const TestDependent(
          token: 'dep-legacy',
          name: 'Helena',
          address: TestDependentAddress(zipCode: null),
        ),
      ),
      act: (cubit) async {
        cubit.changeName('Helena Maria');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentFormStatus.saved);
        expect(cubit.state.showAddressIssues, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'a city the backend does not know falls back to the municipality',
      setUp: () {
        when(() => createDependent(any())).thenAnswer(
          (_) async => const Err<DependentFailure, Dependent>(
            DependentCityNotFoundFailure(),
          ),
        );
        cepResolves();
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        cubit.changeBirthDate('2015-03-22');
        await typeZip(cubit, '72120120');
        cubit.updateNumber('10');
        await cubit.save();
      },
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(cubit.state.failure, const DependentCityNotFoundFailure());
        expect(cubit.state.status, DependentFormStatus.editing);
        expect(address.cityToken, isEmpty);
        expect(address.uf, 'DF');
        expect(address.isCityLocked, isFalse);
        expect(address.zipCode, '72120120');
        expect(address.street, 'QND 12');
        expect(address.number, '10');
        expect(cubit.state.draft.name, 'Helena');
        expect(cubit.state.draft.birthDate, '2015-03-22');
        expect(cubit.state.catalogStates, const [fakeDfState]);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'picking another city clears the city failure',
      setUp: () {
        when(() => createDependent(any())).thenAnswer(
          (_) async => const Err<DependentFailure, Dependent>(
            DependentCityNotFoundFailure(),
          ),
        );
        cepResolves();
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.changeName('Helena');
        await typeZip(cubit, '72120120');
        await cubit.save();
        cubit.selectCity(fakeBrazilianCity(token: 'city-other'));
      },
      verify: (cubit) {
        expect(cubit.state.failure, isNull);
        expect(cubit.state.draft.address.cityToken, 'city-other');
      },
    );
  });

  test('a fixture draft round-trips through a dependent', () {
    final draft = DependentDraft.fromDependent(helenaWithAddress);

    expect(
      draft.address.sameContentAs(
        fakeCompleteDraft(
          neighborhood: 'Taguatinga',
          street: 'QNL 5 Conjunto A',
          number: '12',
          complement: 'Casa 2',
        ),
      ),
      isTrue,
    );
  });

  group('replaceAddress', () {
    blocTest<DependentFormCubit, DependentFormState>(
      'swaps the address and drops a pending lookup and failures',
      setUp: cepResolves,
      build: () => buildCubit(dependent: helenaWithAddress),
      act: (cubit) async {
        cubit.updateZipCode('72120120');
        cubit.replaceAddress(cubit.state.draft.address.withNumber('1'));
        await Future<void>.delayed(cepLookupTestWait);
      },
      verify: (cubit) {
        verifyNever(() => lookupCep(any()));
        expect(cubit.state.isLookingUpCep, isFalse);
        expect(cubit.state.cepFailure, isNull);
        expect(cubit.state.showAddressIssues, isFalse);
      },
    );

    blocTest<DependentFormCubit, DependentFormState>(
      'restores an earlier address exactly, locks included',
      build: () => buildCubit(dependent: helenaWithAddress),
      act: (cubit) {
        final initial = cubit.state.draft.address;
        cubit.updateNumber('99');
        cubit.updateStreet('Outra rua');
        cubit.replaceAddress(initial);
      },
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(address.number, '12');
        expect(address.street, 'QNL 5 Conjunto A');
        expect(address.isCityLocked, isTrue);
        expect(address.isNeighborhoodLocked, isTrue);
      },
    );
  });

  group('confirmAddress', () {
    test('a complete address confirms', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.replaceAddress(fakeCompleteDraft());

      expect(cubit.confirmAddress(), isTrue);
      expect(cubit.state.showAddressIssues, isFalse);
    });

    test('a blank address confirms as no address', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.confirmAddress(), isTrue);
    });

    test('a partial address does not confirm and shows the issues', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.updateStreet('Rua Sete');

      expect(cubit.confirmAddress(), isFalse);
      expect(cubit.state.showsAddressErrors, isTrue);
      expect(cubit.state.addressIssues, isNotEmpty);
    });

    test('a cep that does not exist never confirms', () async {
      cepFails(CepFailure.notFound);
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await typeZip(cubit, '99999999');

      expect(cubit.confirmAddress(), isFalse);
    });

    test('a pending lookup never confirms', () {
      when(
        () => lookupCep(any()),
      ).thenAnswer((_) => Completer<Result<CepFailure, CepLookup>>().future);
      final cubit = buildCubit();
      addTearDown(cubit.close);
      cubit.updateZipCode('72120120');

      expect(cubit.confirmAddress(), isFalse);
    });

    test('a saved address the person never touched confirms', () {
      final cubit = buildCubit(
        dependent: const TestDependent(
          token: 'dep-legacy',
          name: 'Helena',
          address: TestDependentAddress(zipCode: null),
        ),
      );
      addTearDown(cubit.close);

      expect(cubit.confirmAddress(), isTrue);
      expect(cubit.state.addressIssues, isEmpty);
    });
  });

  test('an address left without a city is reported as incomplete', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    cubit.replaceAddress(fakeCompleteDraft().withUf('DF'));

    expect(
      cubit.state.addressIssues,
      contains(PostalAddressIssue.cityRequired),
    );
  });
}
