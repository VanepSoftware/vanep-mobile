import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

void main() {
  test('fromJson maps token as public id and typed user type', () {
    final dto = UserProfileDto.fromJson({
      'token': 'user-token-1',
      'name': 'Ana Motorista',
      'email': 'ana@vanep.com.br',
      'type': 'DRIVER',
    });

    expect(dto.token, 'user-token-1');
    expect(dto.name, 'Ana Motorista');
    expect(dto.email, 'ana@vanep.com.br');
    expect(dto.type, UserType.driver);

    final UserProfile profile = dto;
    expect(profile.type, UserType.driver);
  });

  test('fromJson leaves type null when missing or unknown', () {
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
  });

  test('toJson writes API type strings', () {
    const dto = UserProfileDto(
      token: 'user-token-1',
      name: 'Ana',
      email: 'ana@vanep.com.br',
      type: UserType.client,
    );

    expect(dto.toJson(), {
      'token': 'user-token-1',
      'name': 'Ana',
      'email': 'ana@vanep.com.br',
      'type': 'CLIENT',
    });
  });
}
