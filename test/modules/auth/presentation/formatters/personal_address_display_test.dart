import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/presentation/formatters/personal_address_display.dart';

import '../../personal_address_fixture.dart';

void main() {
  test(
    'formats a complete Taguatinga house with neighborhood and masked zip',
    () {
      final fields = personalAddressDisplayFields(fakePersonalAddress());

      expect(fields.street, 'QND 12, 10, Casa 2');
      expect(fields.neighborhood, 'Taguatinga');
      expect(fields.cityState, 'Brasília/DF');
      expect(fields.zipCode, '72120-120');
    },
  );

  test('keeps neighborhood and zip null when the address omits them', () {
    final fields = personalAddressDisplayFields(
      fakePersonalAddress(
        number: null,
        complement: null,
        neighborhood: null,
        zipCode: null,
      ),
    );

    expect(fields.street, 'QND 12');
    expect(fields.neighborhood, isNull);
    expect(fields.cityState, 'Brasília/DF');
    expect(fields.zipCode, isNull);
  });

  test('does not display districtName as the house neighborhood', () {
    final fields = personalAddressDisplayFields(
      fakePersonalAddress(neighborhood: null, districtName: 'Asa Norte'),
    );

    expect(fields.neighborhood, isNull);
  });
}
