import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/places/place_search_session.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

import '../driver_van_students_fixtures.dart';
import '../driver_van_students_mocks.dart';

const schoolSuggestion = PlaceSuggestion(
  placeId: 'place-1',
  primaryText: 'Col. Horizonte',
  secondaryText: 'São Paulo',
);

void main() {
  late MockPlaceAutocompleteController autocomplete;
  late MockResolveSchool resolveSchool;
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;
  late MockCreateUnlinkedPassenger createUnlinkedPassenger;

  setUpAll(() => registerFallbackValue(FakeUnlinkedPassengerDraft()));

  setUp(() {
    autocomplete = MockPlaceAutocompleteController();
    resolveSchool = MockResolveSchool();
    lookupCep = MockLookupCep();
    listStates = MockListStates();
    listCities = MockListCities();
    createUnlinkedPassenger = MockCreateUnlinkedPassenger();
    when(() => autocomplete.session).thenReturn(PlaceSearchSession());
  });

  UnlinkedPassengerFormCubit buildCubit() => UnlinkedPassengerFormCubit(
    vehicleToken: 'van-1',
    autocomplete: autocomplete,
    resolveSchool: resolveSchool,
    lookupCep: lookupCep,
    listStates: listStates,
    listCities: listCities,
    createUnlinkedPassenger: createUnlinkedPassenger,
    cepLookupDebounce: Duration.zero,
  );

  test('starts with an empty draft for the van', () {
    expect(
      buildCubit().state.draft,
      const UnlinkedPassengerDraft(vehicleToken: 'van-1'),
    );
  });

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'edits the name, the shift, the legs and the times',
    build: buildCubit,
    act: (cubit) => cubit
      ..changeName('Laura')
      ..selectSchoolShift(SchoolShift.morning)
      ..toggleLeg(RouteLeg.outbound, Weekday.monday)
      ..changeTime(Weekday.monday, RouteLeg.outbound, morningPickup)
      ..toggleLeg(RouteLeg.outbound, Weekday.tuesday)
      ..changeNotes('Portão azul'),
    verify: (cubit) {
      final draft = cubit.state.draft;
      expect(draft.name, 'Laura');
      expect(draft.schoolShift, SchoolShift.morning);
      expect(draft.timeOf(Weekday.tuesday, RouteLeg.outbound), morningPickup);
      expect(draft.notes, 'Portão azul');
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'choosing a school resolves it',
    setUp: () =>
        when(() => resolveSchool(placeId: 'place-1', sessionToken: 'session'))
            .thenAnswer((_) async => const Ok(colegioHorizonte)),
    build: buildCubit,
    act: (cubit) => cubit.selectSchool(schoolSuggestion, 'session'),
    verify: (cubit) {
      expect(cubit.state.draft.school, colegioHorizonte);
      expect(cubit.state.isResolvingSchool, isFalse);
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'a school that cannot be resolved shows the failure',
    setUp: () =>
        when(() => resolveSchool(placeId: 'place-1', sessionToken: 'session'))
            .thenAnswer((_) async => const Err(SchoolNetworkFailure())),
    build: buildCubit,
    act: (cubit) => cubit.selectSchool(schoolSuggestion, 'session'),
    verify: (cubit) {
      expect(cubit.state.draft.school, isNull);
      expect(cubit.state.schoolFailure, const SchoolNetworkFailure());
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'a full zip code fills the address from the lookup',
    setUp: () => when(() => lookupCep('01001000')).thenAnswer(
      (_) async => const Ok(
        CepLookup(
          cityToken: 'city-sp',
          cityName: 'São Paulo',
          uf: 'SP',
          street: 'Praça da Sé',
        ),
      ),
    ),
    build: buildCubit,
    act: (cubit) async {
      cubit.changeZipCode('01001-000');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    verify: (cubit) {
      final address = cubit.state.draft.address;
      expect(address.cityToken, 'city-sp');
      expect(address.street, 'Praça da Sé');
      expect(cubit.state.isLookingUpCep, isFalse);
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'an unknown zip code blocks saving',
    setUp: () {
      when(() => lookupCep('01001000'))
          .thenAnswer((_) async => const Err(CepFailure.notFound));
      when(() => listStates())
          .thenAnswer((_) async => const Err(IbgeLocationsFailure.network));
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.changeZipCode('01001000');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    verify: (cubit) {
      expect(cubit.state.cepFailure, CepFailure.notFound);
      expect(cubit.state.blocksSave, isTrue);
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'submitting an incomplete draft shows the errors and sends nothing',
    build: buildCubit,
    act: (cubit) => cubit.submit(),
    verify: (cubit) {
      expect(cubit.state.showErrors, isTrue);
      expect(
        cubit.state.visibleErrors,
        contains(UnlinkedPassengerDraftError.nameRequired),
      );
      verifyNever(() => createUnlinkedPassenger(any()));
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'submitting a complete draft saves it',
    setUp: () =>
        when(() => createUnlinkedPassenger(any()))
            .thenAnswer((_) async => const Ok('new')),
    build: buildCubit,
    seed: () => UnlinkedPassengerFormState(draft: completeDraft()),
    act: (cubit) => cubit.submit(),
    expect: () => [
      UnlinkedPassengerFormState(
        draft: completeDraft(),
        status: UnlinkedPassengerFormStatus.saving,
      ),
      UnlinkedPassengerFormState(
        draft: completeDraft(),
        status: UnlinkedPassengerFormStatus.saved,
      ),
    ],
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'a refused save keeps the draft and shows the failure',
    setUp: () => when(() => createUnlinkedPassenger(any())).thenAnswer(
      (_) async =>
          const Err(DriverStudentRejectedFailure(detail: 'Van inválida.')),
    ),
    build: buildCubit,
    seed: () => UnlinkedPassengerFormState(draft: completeDraft()),
    act: (cubit) => cubit.submit(),
    verify: (cubit) {
      expect(cubit.state.status, UnlinkedPassengerFormStatus.editing);
      expect(
        cubit.state.saveFailure,
        const DriverStudentRejectedFailure(detail: 'Van inválida.'),
      );
      expect(cubit.state.draft, completeDraft());
    },
  );

  test('closing disposes the school search', () async {
    await buildCubit().close();

    verify(() => autocomplete.dispose()).called(1);
  });
  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'applying a time updates every selected day of the same leg only',
    build: buildCubit,
    seed: () => UnlinkedPassengerFormState(
      draft: completeDraft().toggleLeg(Weekday.tuesday, RouteLeg.outbound),
    ),
    act: (cubit) => cubit.applyTimeToEveryDay(RouteLeg.outbound, noonPickup),
    verify: (cubit) {
      expect(
        cubit.state.draft.timeOf(Weekday.monday, RouteLeg.outbound),
        noonPickup,
      );
      expect(
        cubit.state.draft.timeOf(Weekday.tuesday, RouteLeg.outbound),
        noonPickup,
      );
      expect(
        cubit.state.draft.timeOf(Weekday.monday, RouteLeg.homebound),
        noonPickup,
      );
      expect(
        cubit.state.draft.isLegSelected(Weekday.wednesday, RouteLeg.outbound),
        isFalse,
      );
    },
  );

  blocTest<UnlinkedPassengerFormCubit, UnlinkedPassengerFormState>(
    'an unavailable CEP allows selecting a state and searching its cities',
    setUp: () {
      when(() => lookupCep('01001000'))
          .thenAnswer((_) async => const Err(CepFailure.unavailable));
      when(() => listStates())
          .thenAnswer((_) async => const Ok(addressStatesPage));
      when(() => listCities(uf: 'SP'))
          .thenAnswer((_) async => const Ok(addressCitiesPage));
      when(() => listCities(uf: 'SP', search: 'São'))
          .thenAnswer((_) async => const Ok(addressCitiesPage));
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.changeZipCode('01001000');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await cubit.selectUf('SP');
      await cubit.refreshCities('SP', search: 'São');
      cubit.selectCity(addressCity);
      cubit.changeStreet('Rua da escola');
      cubit.changeNumber('20');
      cubit.changeComplement('Casa');
      cubit.changeNeighborhood('Centro');
    },
    verify: (cubit) {
      expect(cubit.state.catalogStates, [addressState]);
      expect(cubit.state.catalogCities, [addressCity]);
      expect(cubit.state.draft.address.cityToken, 'city-sp');
      expect(cubit.state.draft.address.number, '20');
      expect(cubit.state.draft.address.complement, 'Casa');
      expect(cubit.state.draft.address.neighborhood, 'Centro');
      expect(cubit.state.cepFailure, isNull);
    },
  );

  test('stale city results do not replace the newly selected state', () async {
    final pending =
        Completer<
          Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>
        >();
    when(() => listCities(uf: 'SP')).thenAnswer((_) => pending.future);
    when(() => listCities(uf: 'RJ'))
        .thenAnswer((_) async => const Ok(emptyCitiesPage));
    final cubit = buildCubit();
    final first = cubit.selectUf('SP');
    await cubit.selectUf('RJ');
    pending.complete(const Ok(addressCitiesPage));
    await first;
    expect(cubit.state.draft.address.uf, 'RJ');
    expect(cubit.state.catalogCities, isEmpty);
    await cubit.close();
  });

  test(
    'an in-flight CEP cannot overwrite a newer incomplete ZIP code',
    () async {
      final pending = Completer<Result<CepFailure, CepLookup>>();
      when(() => lookupCep('01001000')).thenAnswer((_) => pending.future);
      final cubit = buildCubit();
      cubit.changeZipCode('01001000');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.changeZipCode('01');
      pending.complete(
        const Ok(
          CepLookup(
            cityToken: 'city-sp',
            cityName: 'São Paulo',
            uf: 'SP',
            street: 'Sé',
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.draft.address.zipCode, '01');
      expect(cubit.state.draft.address.cityToken, isEmpty);
      expect(cubit.state.isLookingUpCep, isFalse);
      await cubit.close();
    },
  );
}
