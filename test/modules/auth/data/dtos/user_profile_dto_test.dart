import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

void main() {
  test('fromJson maps token as public id and account fields', () {
    final dto = UserProfileDto.fromJson({
      'token': 'user-token-1',
      'name': 'Ana Motorista',
      'email': 'ana@vanep.com.br',
      'phone': '11999999999',
      'document': '12345678901',
      'birthDate': '1990-05-15',
      'gender': 'FEMALE',
      'type': 'DRIVER',
    });

    expect(dto.token, 'user-token-1');
    expect(dto.name, 'Ana Motorista');
    expect(dto.email, 'ana@vanep.com.br');
    expect(dto.phone, '11999999999');
    expect(dto.document, '12345678901');
    expect(dto.birthDate, '1990-05-15');
    expect(dto.gender, Gender.female);
    expect(dto.type, UserType.driver);

    final UserProfile profile = dto;
    expect(profile.phone, '11999999999');
    expect(profile.document, '12345678901');
    expect(profile.birthDate, '1990-05-15');
    expect(profile.gender, Gender.female);
    expect(profile.type, UserType.driver);
  });

  test('fromJson leaves type and gender null when missing or unknown', () {
    expect(
      UserProfileDto.fromJson({
        'token': 'user-token-2',
        'name': 'Sem tipo',
      }).type,
      isNull,
    );
    expect(
      UserProfileDto.fromJson({
        'token': 'user-token-3',
        'type': 'NOT_A_ROLE',
      }).type,
      isNull,
    );
    expect(
      UserProfileDto.fromJson({
        'token': 'user-token-5',
        'gender': 'UNKNOWN',
      }).gender,
      isNull,
    );
  });

  test('fromJson leaves optional account fields null when omitted', () {
    final dto = UserProfileDto.fromJson({
      'token': 'user-token-4',
      'name': 'Ana',
      'email': 'ana@vanep.com.br',
      'type': 'CLIENT',
    });

    expect(dto.phone, isNull);
    expect(dto.document, isNull);
    expect(dto.birthDate, isNull);
    expect(dto.gender, isNull);
  });

  test('toJson writes API type strings and account fields', () {
    const dto = UserProfileDto(
      token: 'user-token-1',
      name: 'Ana',
      email: 'ana@vanep.com.br',
      phone: '11999999999',
      document: '12345678901',
      birthDate: '1990-05-15',
      gender: Gender.female,
      type: UserType.client,
    );

    expect(dto.toJson(), {
      'token': 'user-token-1',
      'name': 'Ana',
      'email': 'ana@vanep.com.br',
      'phone': '11999999999',
      'document': '12345678901',
      'birthDate': '1990-05-15',
      'gender': 'FEMALE',
      'type': 'CLIENT',
    });
  });
}
