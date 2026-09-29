import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/formatters/postal_address_display.dart';

void main() {
  group('joinPostalStreetLine', () {
    test('joins street, number and complement', () {
      expect(
        joinPostalStreetLine(
          street: 'QND 12',
          number: '10',
          complement: 'Casa 2',
        ),
        'QND 12, 10, Casa 2',
      );
    });

    test('skips blank number and complement', () {
      expect(
        joinPostalStreetLine(street: 'QND 12', number: '  ', complement: null),
        'QND 12',
      );
    });
  });

  group('postalAddressDisplayFields', () {
    test('formats a complete address with a masked zip', () {
      final fields = postalAddressDisplayFields(
        street: 'QND 12',
        number: '10',
        neighborhood: 'Taguatinga',
        cityName: 'Brasília',
        uf: 'DF',
        zipCode: '72120120',
      );

      expect(fields.street, 'QND 12, 10');
      expect(fields.cityState, 'Brasília/DF');
      expect(fields.zipCode, '72120-120');
      expect(fields.details, 'Taguatinga · Brasília/DF · 72120-120');
    });

    test('leaves out the neighborhood and zip that are missing', () {
      final fields = postalAddressDisplayFields(
        street: 'QND 12',
        cityName: 'Brasília',
        uf: 'DF',
        neighborhood: '  ',
      );

      expect(fields.neighborhood, isNull);
      expect(fields.zipCode, isNull);
      expect(fields.details, 'Brasília/DF');
    });

    test('shows only the UF when the city was cleared', () {
      final fields = postalAddressDisplayFields(
        street: 'QND 12',
        cityName: '',
        uf: 'DF',
      );

      expect(fields.cityState, 'DF');
    });
  });

  test('a draft is summarized from its own fields', () {
    final draft = const PostalAddressDraft()
        .withZipCode('72120-120')
        .withCepLookup(
          cityToken: 'city-brasilia',
          cityName: 'Brasília',
          uf: 'DF',
          street: 'QND 12',
          neighborhood: 'Taguatinga',
        )
        .withNumber('10');

    final fields = postalDraftDisplayFields(draft);

    expect(fields.street, 'QND 12, 10');
    expect(fields.details, 'Taguatinga · Brasília/DF · 72120-120');
  });
}
