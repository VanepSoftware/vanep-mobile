import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/dependent_dto.dart';

Map<String, Object?> dependentPayload({
  Object? birthDate = '2015-03-22',
  Object? gender = 'FEMALE',
  Object? address,
}) {
  return {
    'token': 'dep-helena',
    'name': 'Helena Souza',
    'birthDate': birthDate,
    'gender': gender,
    'isDefault': true,
    'address': address,
  };
}

void main() {
  test('reads a dependent with every field', () {
    final dependent = DependentDto.fromJson(
      dependentPayload(
        address: {
          'token': 'addr-1',
          'street': 'QNL 5 Conjunto A',
          'number': '12',
          'complement': 'Casa',
          'zipCode': '72120120',
          'neighborhood': 'Taguatinga',
          'cityToken': 'city-brasilia',
          'district': null,
          'cityName': 'Brasília',
          'stateUf': 'DF',
        },
      ),
    );

    expect(dependent.token, 'dep-helena');
    expect(dependent.name, 'Helena Souza');
    expect(dependent.birthDate, '2015-03-22');
    expect(dependent.gender, Gender.female);
    expect(dependent.isDefault, isTrue);
    expect(dependent.address?.street, 'QNL 5 Conjunto A');
    expect(dependent.address?.zipCode, '72120120');
    expect(dependent.address?.neighborhood, 'Taguatinga');
    expect(dependent.address?.cityToken, 'city-brasilia');
    expect(dependent.address?.cityName, 'Brasília');
    expect(dependent.address?.stateUf, 'DF');
  });

  test('a district sent by the API is ignored', () {
    final dependent = DependentDto.fromJson(
      dependentPayload(
        address: {
          'token': 'addr-1',
          'street': 'Rua do Embarque',
          'district': 'Asa Norte',
          'cityToken': 'city-brasilia',
          'cityName': 'Brasília',
          'stateUf': 'DF',
        },
      ),
    );

    expect(dependent.address?.neighborhood, isNull);
    expect(dependent.address?.street, 'Rua do Embarque');
  });

  test('reads a dependent without birth date, gender or address', () {
    final dependent = DependentDto.fromJson(
      dependentPayload(birthDate: null, gender: null),
    );

    expect(dependent.birthDate, isNull);
    expect(dependent.gender, isNull);
    expect(dependent.address, isNull);
  });

  test('an unknown gender does not break the read', () {
    final dependent = DependentDto.fromJson(
      dependentPayload(gender: 'UNICORN'),
    );

    expect(dependent.gender, isNull);
  });

  test('missing optional keys fall back instead of throwing', () {
    final dependent = DependentDto.fromJson(const {'token': 'dep-1'});

    expect(dependent.name, '');
    expect(dependent.isDefault, isFalse);
  });

  test('an address without the optional parts is read', () {
    final dependent = DependentDto.fromJson(
      dependentPayload(
        address: {
          'token': 'addr-1',
          'street': 'Rua do Embarque',
          'zipCode': '72120120',
          'cityToken': 'city-brasilia',
          'cityName': 'Brasília',
          'stateUf': 'DF',
        },
      ),
    );

    expect(dependent.address?.neighborhood, isNull);
    expect(dependent.address?.number, isNull);
    expect(dependent.address?.complement, isNull);
  });
}
