import 'package:flutter_test/flutter_test.dart';

import '../../ibge_locations_fixture.dart';

void main() {
  test('cep lookups with the same fields are equal', () {
    expect(fakeCepLookup(), fakeCepLookup());
  });

  test('cep lookups that differ in any field are not equal', () {
    expect(fakeCepLookup(cityToken: 'city-goiania'), isNot(fakeCepLookup()));
    expect(fakeCepLookup(cityName: 'Goiânia'), isNot(fakeCepLookup()));
    expect(fakeCepLookup(uf: 'GO'), isNot(fakeCepLookup()));
    expect(fakeCepLookup(street: null), isNot(fakeCepLookup()));
    expect(fakeCepLookup(neighborhood: null), isNot(fakeCepLookup()));
  });

  test('street and neighborhood may be null', () {
    final lookup = fakeCepLookup(street: null, neighborhood: null);

    expect(lookup.street, isNull);
    expect(lookup.neighborhood, isNull);
    expect(lookup.cityToken, 'city-brasilia');
  });

  test('page equality uses items and paging fields, not content', () {
    final page = fakeIbgeLocationsPage(items: [fakeDfState]);
    final same = fakeIbgeLocationsPage(items: [fakeDfState]);
    final otherItems = fakeIbgeLocationsPage(items: [fakeGoState]);
    final otherPaging = fakeIbgeLocationsPage(
      items: [fakeDfState],
      totalElements: 27,
      totalPages: 2,
      number: 1,
      size: 30,
    );

    expect(page, same);
    expect(page, isNot(otherItems));
    expect(page, isNot(otherPaging));
    expect(page.items, [fakeDfState]);
    expect(page.totalElements, 1);
    expect(page.totalPages, 1);
    expect(page.number, 0);
    expect(page.size, 20);
  });
}
