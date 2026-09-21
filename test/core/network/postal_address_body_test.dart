import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/network/postal_address_body.dart';

void main() {
  test('carries the required postal fields', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: 'QND 12',
      zipCode: '72120120',
    );

    expect(body['cityToken'], 'city-brasilia');
    expect(body['street'], 'QND 12');
    expect(body['zipCode'], '72120120');
  });

  test('the three optionals are always present, null when never filled', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: 'QND 12',
      zipCode: '72120120',
    );

    expect(body.containsKey('number'), isTrue);
    expect(body.containsKey('complement'), isTrue);
    expect(body.containsKey('neighborhood'), isTrue);
    expect(body['number'], isNull);
    expect(body['complement'], isNull);
    expect(body['neighborhood'], isNull);
  });

  test('filled optionals travel as trimmed strings', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: 'QND 12',
      zipCode: '72120120',
      number: ' 10 ',
      complement: 'Casa 2',
      neighborhood: 'Taguatinga',
    );

    expect(body, {
      'cityToken': 'city-brasilia',
      'street': 'QND 12',
      'zipCode': '72120120',
      'number': '10',
      'complement': 'Casa 2',
      'neighborhood': 'Taguatinga',
    });
  });

  test('blank optionals travel as explicit JSON nulls', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: 'QND 12',
      zipCode: '72120120',
      number: '',
      complement: '   ',
      neighborhood: '',
    );

    expect(body['number'], isNull);
    expect(body['complement'], isNull);
    expect(body['neighborhood'], isNull);
    expect(body.containsKey('number'), isTrue);
  });

  test('a masked zip is sent as eight digits without the hyphen', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: 'QND 12',
      zipCode: '70040-010',
    );

    expect(body['zipCode'], '70040010');
  });

  test('the street is trimmed', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: '  QND 12  ',
      zipCode: '72120120',
    );

    expect(body['street'], 'QND 12');
  });

  test('the body is postal keys only, never Places or display geography', () {
    final body = postalAddressToJson(
      cityToken: 'city-brasilia',
      street: 'QND 12',
      zipCode: '72120120',
      number: '10',
    );

    expect(
      body.keys,
      unorderedEquals([
        'cityToken',
        'street',
        'zipCode',
        'number',
        'complement',
        'neighborhood',
      ]),
    );
    expect(body.containsKey('placeId'), isFalse);
    expect(body.containsKey('sessionToken'), isFalse);
    expect(body.containsKey('stateToken'), isFalse);
    expect(body.containsKey('cityName'), isFalse);
    expect(body.containsKey('uf'), isFalse);
  });
}
