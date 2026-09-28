import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';

import '../../ibge_locations_fixture.dart';
import '../../ibge_locations_mocks.dart';

void main() {
  late MockIbgeLocationsRepository repository;

  setUp(() {
    repository = MockIbgeLocationsRepository();
  });

  test('LookupCep returns the lookup when found', () async {
    final lookup = fakeCepLookup();
    when(
      () => repository.lookupCep(any()),
    ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(lookup));

    final result = await LookupCep(repository)('72120120');

    expect(result.valueOrNull, lookup);
    verify(() => repository.lookupCep('72120120')).called(1);
  });

  test('LookupCep returns a lookup with a null street', () async {
    final lookup = fakeCepLookup(street: null, neighborhood: null);
    when(
      () => repository.lookupCep(any()),
    ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(lookup));

    final result = await LookupCep(repository)('70000000');

    expect(result.isOk, isTrue);
    expect(result.valueOrNull?.street, isNull);
    expect(result.valueOrNull?.neighborhood, isNull);
  });

  test('LookupCep forwards failures', () async {
    when(() => repository.lookupCep(any())).thenAnswer(
      (_) async => const Err<CepFailure, CepLookup>(CepFailure.notFound),
    );

    final result = await LookupCep(repository)('00000000');

    expect(result.errorOrNull, CepFailure.notFound);
  });

  test('ListStates returns a page of states', () async {
    final page = fakeIbgeLocationsPage(items: [fakeDfState], size: 30);
    when(
      () => repository.listStates(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer(
      (_) async =>
          Ok<IbgeLocationsFailure, IbgeLocationsPage<BrazilianState>>(page),
    );

    final result = await ListStates(repository)();

    expect(result.valueOrNull, page);
    verify(() => repository.listStates(page: 0, size: 30)).called(1);
  });

  test('ListStates forwards failures', () async {
    when(
      () => repository.listStates(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer(
      (_) async =>
          const Err<IbgeLocationsFailure, IbgeLocationsPage<BrazilianState>>(
            IbgeLocationsFailure.network,
          ),
    );

    final result = await ListStates(repository)();

    expect(result.errorOrNull, IbgeLocationsFailure.network);
  });

  test('ListCities requires uf and returns a page of cities', () async {
    final page = fakeIbgeLocationsPage(items: [fakeBrazilianCity()]);
    when(
      () => repository.listCities(uf: 'DF', search: null, page: 0, size: 20),
    ).thenAnswer(
      (_) async =>
          Ok<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>(page),
    );

    final result = await ListCities(repository)(uf: 'DF');

    expect(result.valueOrNull, page);
    verify(
      () => repository.listCities(uf: 'DF', search: null, page: 0, size: 20),
    ).called(1);
  });

  test('ListCities forwards failures', () async {
    when(
      () => repository.listCities(uf: 'XX', search: null, page: 0, size: 20),
    ).thenAnswer(
      (_) async =>
          const Err<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>(
            IbgeLocationsFailure.ufNotFound,
          ),
    );

    final result = await ListCities(repository)(uf: 'XX');

    expect(result.errorOrNull, IbgeLocationsFailure.ufNotFound);
  });
}
