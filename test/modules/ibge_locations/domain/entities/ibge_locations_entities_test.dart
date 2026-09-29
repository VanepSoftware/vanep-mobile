import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';

import '../../ibge_locations_fixture.dart';

void main() {
  test('states with the same fields are equal', () {
    expect(fakeDfState, fakeDfState);
  });

  test('states that differ in any field are not equal', () {
    expect(fakeGoState, isNot(fakeDfState));
    expect(
      const BrazilianState(
        token: 'state-df',
        name: 'Distrito Federal',
        uf: 'DF',
        active: false,
      ),
      isNot(fakeDfState),
    );
  });

  test('cities with the same fields are equal', () {
    expect(fakeBrazilianCity(), fakeBrazilianCity());
  });

  test('cities that differ in any field are not equal', () {
    expect(
      fakeBrazilianCity(token: 'city-goiania'),
      isNot(fakeBrazilianCity()),
    );
    expect(fakeBrazilianCity(name: 'Goiânia'), isNot(fakeBrazilianCity()));
    expect(
      fakeBrazilianCity(stateToken: 'state-go'),
      isNot(fakeBrazilianCity()),
    );
    expect(fakeBrazilianCity(stateUf: 'GO'), isNot(fakeBrazilianCity()));
    expect(fakeBrazilianCity(active: false), isNot(fakeBrazilianCity()));
    expect(
      fakeBrazilianCity(createdAt: DateTime.utc(2026, 1, 1)),
      isNot(fakeBrazilianCity()),
    );
  });

  test('city identity fields do not include an ibge code', () {
    expect(fakeBrazilianCity().props, [
      'city-brasilia',
      'Brasília',
      'state-df',
      'DF',
      true,
      null,
    ]);
  });
}
