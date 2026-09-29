import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';

import '../../personal_address_fixture.dart';

void main() {
  test('addresses with the same fields are equal', () {
    expect(fakePersonalAddress(), fakePersonalAddress());
  });

  test('addresses that differ in any field are not equal', () {
    expect(
      fakePersonalAddress(token: 'addr-other'),
      isNot(fakePersonalAddress()),
    );
    expect(
      fakePersonalAddress(street: 'SQS 102'),
      isNot(fakePersonalAddress()),
    );
    expect(fakePersonalAddress(number: null), isNot(fakePersonalAddress()));
    expect(fakePersonalAddress(complement: null), isNot(fakePersonalAddress()));
    expect(fakePersonalAddress(zipCode: null), isNot(fakePersonalAddress()));
    expect(
      fakePersonalAddress(neighborhood: null),
      isNot(fakePersonalAddress()),
    );
    expect(
      fakePersonalAddress(districtName: 'Asa Norte'),
      isNot(fakePersonalAddress()),
    );
    expect(
      fakePersonalAddress(districtToken: 'dist-asa-norte'),
      isNot(fakePersonalAddress()),
    );
    expect(
      fakePersonalAddress(cityName: 'Goiânia'),
      isNot(fakePersonalAddress()),
    );
    expect(
      fakePersonalAddress(cityToken: 'city-goiania'),
      isNot(fakePersonalAddress()),
    );
    expect(fakePersonalAddress(stateUf: 'GO'), isNot(fakePersonalAddress()));
    expect(
      fakePersonalAddress(countryIsoCode: 'AR'),
      isNot(fakePersonalAddress()),
    );
  });

  group('toDraft', () {
    test('carries the postal fields and drops the display-only ones', () {
      final draft = fakePersonalAddress(
        districtName: 'Asa Norte',
        districtToken: 'dist-asa-norte',
      ).toDraft();

      expect(
        draft,
        PostalAddressDraft.fromParts(
          zipCode: '72120120',
          cityToken: 'city-brasilia',
          cityName: 'Brasília',
          uf: 'DF',
          street: 'QND 12',
          neighborhood: 'Taguatinga',
          number: '10',
          complement: 'Casa 2',
        ),
      );
    });

    test('turns null optionals into empty text', () {
      final draft = fakePersonalAddress(
        number: null,
        complement: null,
        neighborhood: null,
        zipCode: null,
      ).toDraft();

      expect(draft.number, '');
      expect(draft.complement, '');
      expect(draft.neighborhood, '');
      expect(draft.zipCode, '');
    });

    test('starts locked on the saved city and neighborhood, like a 200', () {
      final draft = fakePersonalAddress().toDraft();

      expect(draft.isCityLocked, isTrue);
      expect(draft.isNeighborhoodLocked, isTrue);
      expect(draft.isZipCodeUnknown, isFalse);
    });

    test('keeps the neighborhood open when none was saved', () {
      final draft = fakePersonalAddress(neighborhood: null).toDraft();

      expect(draft.isCityLocked, isTrue);
      expect(draft.isNeighborhoodLocked, isFalse);
    });

    test('a saved address is not dirty against its own draft', () {
      final address = fakePersonalAddress();

      expect(address.toDraft().sameContentAs(address.toDraft()), isTrue);
    });
  });
}
