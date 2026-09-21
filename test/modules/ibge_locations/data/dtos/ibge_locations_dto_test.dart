import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/dtos/brazilian_city_dto.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/dtos/brazilian_state_dto.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/dtos/cep_lookup_dto.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/dtos/ibge_locations_page_dto.dart';

import '../../ibge_locations_fixture.dart';

void main() {
  test('state item maps onto BrazilianState', () {
    expect(brazilianStateFromJson(fakeBrazilianStateJson()), fakeDfState);
  });

  test('city item token is the cityToken', () {
    final city = brazilianCityFromJson(fakeBrazilianCityJson());

    expect(city.token, 'city-brasilia');
    expect(city, fakeBrazilianCity());
  });

  test('cep lookup maps street and neighborhood as null when absent', () {
    final lookup = cepLookupFromJson(
      fakeCepLookupJson(street: null, neighborhood: null),
    );

    expect(lookup, fakeCepLookup(street: null, neighborhood: null));
    expect(lookup.street, isNull);
    expect(lookup.neighborhood, isNull);
    expect(lookup.cityToken, 'city-brasilia');
  });

  test('cep lookup maps a filled street and neighborhood', () {
    expect(cepLookupFromJson(fakeCepLookupJson()), fakeCepLookup());
  });

  test(
    'spring page is read from content, totalElements, totalPages, number and size',
    () {
      final page = ibgeLocationsPageFromJson(
        fakeIbgeLocationsPageJson(
          content: [
            fakeBrazilianStateJson(),
            fakeBrazilianStateJson(token: 'state-go', name: 'Goiás', uf: 'GO'),
          ],
          totalElements: 27,
          totalPages: 1,
          number: 0,
          size: 30,
        ),
        brazilianStateFromJson,
      );

      expect(page.items, [fakeDfState, fakeGoState]);
      expect(page.totalElements, 27);
      expect(page.totalPages, 1);
      expect(page.number, 0);
      expect(page.size, 30);
    },
  );
}
