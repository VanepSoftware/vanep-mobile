import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/environment/environment.dart';

void main() {
  const environment = Environment(
    authBaseUrl: 'http://localhost:8080',
    oauthClientId: 'vanep-mobile',
  );

  test(
    'userPersonalAddressEndpoint is authBaseUrl plus /api/user/me/address',
    () {
      expect(
        environment.userPersonalAddressEndpoint,
        'http://localhost:8080/api/user/me/address',
      );
    },
  );

  test(
    'cepLookupEndpoint interpolates digits-only CEP into /api/cep/{cep}',
    () {
      expect(
        environment.cepLookupEndpoint('70040010'),
        'http://localhost:8080/api/cep/70040010',
      );
    },
  );

  test('cepLookupEndpoint never puts a hyphen in the path', () {
    expect(
      environment.cepLookupEndpoint('70040-010'),
      'http://localhost:8080/api/cep/70040010',
    );
  });

  test('statesEndpoint is authBaseUrl plus /api/states', () {
    expect(environment.statesEndpoint, 'http://localhost:8080/api/states');
  });

  test('citiesEndpoint is authBaseUrl plus /api/cities', () {
    expect(environment.citiesEndpoint, 'http://localhost:8080/api/cities');
  });
}
