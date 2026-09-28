import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/personal_address_dto.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';

import '../../personal_address_fixture.dart';

void main() {
  test('GET/PUT response maps onto PersonalAddress', () {
    final dto = PersonalAddressDto.fromJson(fakePersonalAddressJson());
    final PersonalAddress address = personalAddressFromDto(dto);

    expect(address, fakePersonalAddress());
  });

  test(
    'number, complement, neighborhood, district and zipCode may be null',
    () {
      final dto = PersonalAddressDto.fromJson(
        fakePersonalAddressJson(
          number: null,
          complement: null,
          zipCode: null,
          neighborhood: null,
          districtName: null,
          districtToken: null,
        ),
      );

      expect(
        personalAddressFromDto(dto),
        fakePersonalAddress(
          number: null,
          complement: null,
          zipCode: null,
          neighborhood: null,
          districtName: null,
          districtToken: null,
        ),
      );
    },
  );

  test('omitted optional keys map to null, not empty strings', () {
    final address = personalAddressFromDto(
      PersonalAddressDto.fromJson(fakePersonalAddressJsonWithoutOptionals()),
    );

    expect(address.number, isNull);
    expect(address.complement, isNull);
    expect(address.zipCode, isNull);
    expect(address.neighborhood, isNull);
    expect(address.districtName, isNull);
    expect(address.districtToken, isNull);
  });

  test('response json without googlePlaceId still maps', () {
    expect(fakePersonalAddressJson().containsKey('googlePlaceId'), isFalse);
    expect(
      personalAddressFromDto(
        PersonalAddressDto.fromJson({
          ...fakePersonalAddressJson(),
          'googlePlaceId': 'ChIJ-legacy',
        }),
      ),
      fakePersonalAddress(),
    );
  });

  test('PUT json is cityToken street zipCode plus the three optionals', () {
    final body = personalAddressUpsertBody(
      fakePersonalAddressWrite(
        number: '10',
        complement: 'Casa 2',
        neighborhood: 'Taguatinga',
      ),
    );

    expect(body, {
      'cityToken': 'city-brasilia',
      'street': 'QND 12',
      'zipCode': '72120120',
      'number': '10',
      'complement': 'Casa 2',
      'neighborhood': 'Taguatinga',
    });
    expect(body.containsKey('placeId'), isFalse);
    expect(body.containsKey('sessionToken'), isFalse);
    expect(body.containsKey('googlePlaceId'), isFalse);
  });

  test('PUT json sends empty optionals as explicit null', () {
    final body = personalAddressUpsertBody(fakePersonalAddressWrite());

    expect(body, {
      'cityToken': 'city-brasilia',
      'street': 'QND 12',
      'zipCode': '72120120',
      'number': null,
      'complement': null,
      'neighborhood': null,
    });
    expect(body.containsKey('placeId'), isFalse);
  });
}
