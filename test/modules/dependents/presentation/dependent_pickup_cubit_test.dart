import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor_status.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_pickup_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
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
  late MockUpdateDependent updateDependent;
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;

  setUpAll(registerDependentFallbackValues);

  setUp(() {
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

  DependentPickupCubit buildCubit({
    Dependent dependent = testHelenaDependent,
  }) => DependentPickupCubit(
    dependent: dependent,
    updateDependent: updateDependent,
    lookupCep: lookupCep,
    listStates: listStates,
    listCities: listCities,
    cepLookupDebounce: Duration.zero,
  );

  void cepResolves([CepLookup? lookup]) {
    when(() => lookupCep(any())).thenAnswer(
      (_) async => Ok<CepFailure, CepLookup>(lookup ?? fakeCepLookup()),
    );
  }

  void cepFails(CepFailure failure) {
    when(() => lookupCep(any()))
        .thenAnswer((_) async => Err<CepFailure, CepLookup>(failure));
  }

  void updateReturns(Result<DependentFailure, Dependent> result) {
    when(
      () => updateDependent(
        snapshot: any(named: 'snapshot'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async => result);
  }

  void updateSucceeds() => updateReturns(const Ok(testHelenaDependent));

  void verifyNoUpdate() {
    verifyNever(
      () => updateDependent(
        snapshot: any(named: 'snapshot'),
        draft: any(named: 'draft'),
      ),
    );
  }

  DependentDraft sentDraft(Dependent snapshot) {
    return verify(
          () => updateDependent(
            snapshot: snapshot,
            draft: captureAny(named: 'draft'),
          ),
        ).captured.single
        as DependentDraft;
  }

  Future<void> typeZip(DependentPickupCubit cubit, String zip) async {
    cubit.updateZipCode(zip);
    await Future<void>.delayed(cepLookupTestWait);
  }

  group('cep lookup', () {
    blocTest<DependentPickupCubit, DependentPickupState>(
      'eight digits look the cep up with digits only',
      setUp: cepResolves,
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '72120-120'),
      verify: (_) => verify(() => lookupCep('72120120')).called(1),
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'fewer than eight digits never look the cep up',
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '7212012'),
      verify: (cubit) {
        verifyNever(() => lookupCep(any()));
        expect(cubit.state.isLookingUpCep, isFalse);
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
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

    blocTest<DependentPickupCubit, DependentPickupState>(
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

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a 200 without neighborhood leaves the field open',
      setUp: () => cepResolves(fakeCepLookup(neighborhood: null)),
      build: buildCubit,
      act: (cubit) => typeZip(cubit, '72120120'),
      verify: (cubit) {
        expect(cubit.state.draft.address.neighborhood, isEmpty);
        expect(cubit.state.draft.address.isNeighborhoodLocked, isFalse);
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
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
      CepFailure.unavailable,
      CepFailure.network,
      CepFailure.unexpected,
    ]) {
      blocTest<DependentPickupCubit, DependentPickupState>(
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

    for (final failure in [CepFailure.notFound, CepFailure.rateLimited]) {
      blocTest<DependentPickupCubit, DependentPickupState>(
        'a $failure cep blocks the save until the cep changes',
        setUp: () => cepFails(failure),
        build: buildCubit,
        act: (cubit) async {
          await typeZip(cubit, '72120120');
          await cubit.save();
        },
        verify: (cubit) {
          expect(cubit.state.cepFailure, failure);
          expect(cubit.state.draft.address.isZipCodeUnknown, isTrue);
          expect(cubit.state.isAddressBlockingSave, isTrue);
          expect(cubit.state.canSave, isFalse);
          verifyNoUpdate();
        },
      );

      blocTest<DependentPickupCubit, DependentPickupState>(
        'picking a state or city does not lift the $failure cep block',
        setUp: () => cepFails(failure),
        build: buildCubit,
        act: (cubit) async {
          await typeZip(cubit, '72120120');
          await cubit.selectUf('DF');
          cubit.selectCity(fakeBrazilianCity());
        },
        verify: (cubit) {
          expect(cubit.state.cepFailure, failure);
          expect(cubit.state.isAddressBlockingSave, isTrue);
        },
      );

      blocTest<DependentPickupCubit, DependentPickupState>(
        'editing the cep after a $failure one lifts the block',
        setUp: () => cepFails(failure),
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
    }

    blocTest<DependentPickupCubit, DependentPickupState>(
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

    blocTest<DependentPickupCubit, DependentPickupState>(
      'the save waits for a pending lookup',
      setUp: () {
        updateSucceeds();
        when(
          () => lookupCep(any()),
        ).thenAnswer((_) => Completer<Result<CepFailure, CepLookup>>().future);
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.updateZipCode('72120120');
        await cubit.save();
      },
      verify: (cubit) {
        verifyNoUpdate();
        expect(cubit.state.isAddressBlockingSave, isTrue);
      },
    );
  });

  group('picker', () {
    blocTest<DependentPickupCubit, DependentPickupState>(
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

    blocTest<DependentPickupCubit, DependentPickupState>(
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

    group('a stale city search answer', () {
      late Completer<
        Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>
      >
      staleSearch;
      late Completer<
        Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>
      >
      freshSearch;

      blocTest<DependentPickupCubit, DependentPickupState>(
        'does not overwrite a newer search that resolved first',
        setUp: () {
          staleSearch = Completer();
          freshSearch = Completer();
          when(() => listCities(uf: 'DF', search: 'bra'))
              .thenAnswer((_) => staleSearch.future);
          when(() => listCities(uf: 'DF', search: 'brasi'))
              .thenAnswer((_) => freshSearch.future);
        },
        build: buildCubit,
        act: (cubit) async {
          unawaited(cubit.refreshCities('DF', search: 'bra'));
          unawaited(cubit.refreshCities('DF', search: 'brasi'));
          freshSearch.complete(
            Ok(fakeIbgeLocationsPage(items: [fakeBrazilianCity()])),
          );
          await Future<void>.delayed(Duration.zero);
          staleSearch.complete(Ok(fakeIbgeLocationsPage(items: const [])));
          await Future<void>.delayed(Duration.zero);
        },
        verify: (cubit) {
          expect(cubit.state.catalogCities, [fakeBrazilianCity()]);
        },
      );
    });

    blocTest<DependentPickupCubit, DependentPickupState>(
      'no city is ever listed without a state',
      build: buildCubit,
      act: (cubit) => cubit.refreshCities(''),
      verify: (_) => verifyNever(() => listCities(uf: any(named: 'uf'))),
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
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

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a failing catalog is surfaced',
      setUp: () {
        when(() => listCities(uf: any(named: 'uf')))
            .thenAnswer((_) async => const Err(IbgeLocationsFailure.network));
      },
      build: buildCubit,
      act: (cubit) => cubit.refreshCities('DF'),
      verify: (cubit) =>
          expect(cubit.state.catalogFailure, IbgeLocationsFailure.network),
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
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

    blocTest<DependentPickupCubit, DependentPickupState>(
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
    blocTest<DependentPickupCubit, DependentPickupState>(
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

  group('save', () {
    test('an untouched address has nothing to save', () {
      final cubit = buildCubit(dependent: helenaWithAddress);
      addTearDown(cubit.close);

      expect(cubit.state.hasChanges, isFalse);
      expect(cubit.state.canSave, isFalse);
    });

    blocTest<DependentPickupCubit, DependentPickupState>(
      'saving touches only the address and hands back the dependent',
      setUp: updateSucceeds,
      build: () => buildCubit(dependent: helenaWithAddress),
      act: (cubit) async {
        cubit.updateNumber('99');
        await cubit.save();
      },
      verify: (cubit) {
        final draft = sentDraft(helenaWithAddress);
        expect(draft.address.number, '99');
        expect(
          buildDependentChangesForUpdate(
            draft: draft,
            snapshot: helenaWithAddress,
          ).touchedFields,
          {DependentField.address},
        );
        expect(cubit.state.status, DependentEditorStatus.saved);
        expect(cubit.state.saved, testHelenaDependent);
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a partial address blocks the save without a request',
      setUp: updateSucceeds,
      build: buildCubit,
      act: (cubit) async {
        cubit.updateStreet('Rua Sete');
        await cubit.save();
      },
      verify: (cubit) {
        verifyNoUpdate();
        expect(cubit.state.showsAddressErrors, isTrue);
        expect(cubit.state.status, DependentEditorStatus.editing);
        expect(
          cubit.state.draft.address.issues,
          contains(PostalAddressIssue.zipCodeInvalid),
        );
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'the address errors stay until the address is blank again',
      build: buildCubit,
      act: (cubit) async {
        cubit.updateStreet('Rua Sete');
        await cubit.save();
        cubit.updateStreet('');
      },
      verify: (cubit) {
        expect(cubit.state.showAddressIssues, isTrue);
        expect(cubit.state.showsAddressErrors, isFalse);
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a complete address reaches the use case',
      setUp: () {
        updateSucceeds();
        cepResolves();
      },
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        cubit.updateNumber('10');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentEditorStatus.saved);
        final draft = sentDraft(testHelenaDependent);
        expect(draft.address.cityToken, 'city-brasilia');
        expect(draft.address.zipCode, '72120120');
        expect(draft.address.number, '10');
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a failure keeps the address and shows it',
      setUp: () => updateReturns(const Err(DependentNetworkFailure())),
      build: () => buildCubit(dependent: helenaWithAddress),
      act: (cubit) async {
        cubit.updateNumber('99');
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.status, DependentEditorStatus.editing);
        expect(cubit.state.failure, const DependentNetworkFailure());
        expect(cubit.state.draft.address.number, '99');
        expect(cubit.state.saved, isNull);
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a city the backend does not know falls back to the municipality',
      setUp: () {
        updateReturns(const Err(DependentCityNotFoundFailure()));
        cepResolves();
      },
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        cubit.updateNumber('10');
        await cubit.save();
      },
      verify: (cubit) {
        final address = cubit.state.draft.address;
        expect(cubit.state.failure, const DependentCityNotFoundFailure());
        expect(cubit.state.status, DependentEditorStatus.editing);
        expect(address.cityToken, isEmpty);
        expect(address.uf, 'DF');
        expect(address.isCityLocked, isFalse);
        expect(address.zipCode, '72120120');
        expect(address.street, 'QND 12');
        expect(address.number, '10');
        expect(cubit.state.catalogStates, const [fakeDfState]);
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'picking another city clears the city failure',
      setUp: () {
        updateReturns(const Err(DependentCityNotFoundFailure()));
        cepResolves();
      },
      build: buildCubit,
      act: (cubit) async {
        await typeZip(cubit, '72120120');
        cubit.updateNumber('10');
        await cubit.save();
        cubit.selectCity(fakeBrazilianCity(token: 'city-other'));
      },
      verify: (cubit) {
        expect(cubit.state.failure, isNull);
        expect(cubit.state.draft.address.cityToken, 'city-other');
      },
    );

    blocTest<DependentPickupCubit, DependentPickupState>(
      'a saved address the person never touched is never blocked',
      build: () => buildCubit(
        dependent: const TestDependent(
          token: 'dep-legacy',
          name: 'Helena',
          address: TestDependentAddress(zipCode: null),
        ),
      ),
      verify: (cubit) {
        expect(cubit.state.addressIssues, isEmpty);
        expect(cubit.state.showsAddressErrors, isFalse);
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

  test('an address left without a city is reported as incomplete', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    cubit.emitAddress(fakeCompleteDraft().withUf('DF'));

    expect(
      cubit.state.addressIssues,
      contains(PostalAddressIssue.cityRequired),
    );
  });
}
