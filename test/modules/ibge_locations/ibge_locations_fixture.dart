import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';

const fakeDfState = BrazilianState(
  token: 'state-df',
  name: 'Distrito Federal',
  uf: 'DF',
  active: true,
);

const fakeGoState = BrazilianState(
  token: 'state-go',
  name: 'Goiás',
  uf: 'GO',
  active: true,
);

BrazilianCity fakeBrazilianCity({
  String token = 'city-brasilia',
  String name = 'Brasília',
  String stateToken = 'state-df',
  String stateUf = 'DF',
  bool active = true,
  DateTime? createdAt,
}) {
  return BrazilianCity(
    token: token,
    name: name,
    stateToken: stateToken,
    stateUf: stateUf,
    active: active,
    createdAt: createdAt,
  );
}

CepLookup fakeCepLookup({
  String cityToken = 'city-brasilia',
  String cityName = 'Brasília',
  String uf = 'DF',
  String? street = 'QND 12',
  String? neighborhood = 'Taguatinga',
}) {
  return CepLookup(
    cityToken: cityToken,
    cityName: cityName,
    uf: uf,
    street: street,
    neighborhood: neighborhood,
  );
}

IbgeLocationsPage<T> fakeIbgeLocationsPage<T>({
  required List<T> items,
  int totalElements = 1,
  int totalPages = 1,
  int number = 0,
  int size = 20,
}) {
  return IbgeLocationsPage<T>(
    items: items,
    totalElements: totalElements,
    totalPages: totalPages,
    number: number,
    size: size,
  );
}
