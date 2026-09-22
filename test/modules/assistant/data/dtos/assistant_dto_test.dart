import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_invite_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_lean_signup_request_dto.dart';
import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_van_dto.dart';

void main() {
  group('AssistantInviteDto', () {
    test('parses full invite payload with nested driver object', () {
      final json = {
        'token': 'inv-123',
        'driver': {
          'name': 'Carlos Motorista',
          'photo': 'https://example.com/carlos.png',
          'rating': 4.85,
        },
        'vehicleDescription': 'Mercedes Sprinter 2024',
        'expiresAt': '2026-09-30T10:00:00.000Z',
        'status': 'PENDING',
      };

      final dto = AssistantInviteDto.fromJson(json);

      expect(dto.token, 'inv-123');
      expect(dto.driverName, 'Carlos Motorista');
      expect(dto.driverPhoto, 'https://example.com/carlos.png');
      expect(dto.driverRating, 4.85);
      expect(dto.vehicleDescription, 'Mercedes Sprinter 2024');
      expect(dto.status, 'PENDING');
      expect(dto.expiresAt.year, 2026);
    });

    test('parses flat driver fields as fallback', () {
      final json = {
        'token': 'inv-flat',
        'driverName': 'Ana Motorista',
        'driverPhoto': 'https://example.com/ana.png',
        'driverRating': 5.0,
        'status': 'ACCEPTED',
      };

      final dto = AssistantInviteDto.fromJson(json);

      expect(dto.token, 'inv-flat');
      expect(dto.driverName, 'Ana Motorista');
      expect(dto.driverPhoto, 'https://example.com/ana.png');
      expect(dto.driverRating, 5.0);
      expect(dto.status, 'ACCEPTED');
    });

    test('serializes to json', () {
      final dto = AssistantInviteDto(
        token: 'tok-abc',
        driverName: 'Marcos',
        vehicleDescription: 'Van Branca',
        expiresAt: DateTime.utc(2026, 10, 1),
        status: 'PENDING',
      );

      final json = dto.toJson();

      expect(json['token'], 'tok-abc');
      expect(json['driverName'], 'Marcos');
      expect(json['vehicleDescription'], 'Van Branca');
      expect(json['status'], 'PENDING');
    });
  });

  group('AssistantVanDto', () {
    test('parses and serializes correctly', () {
      final json = {
        'token': 'van-1',
        'driverToken': 'drv-1',
        'driverName': 'Roberto Silva',
        'plate': 'BRA2E19',
        'model': 'Ducato Maxi',
        'shift': 'MORNING',
      };

      final dto = AssistantVanDto.fromJson(json);

      expect(dto.token, 'van-1');
      expect(dto.driverToken, 'drv-1');
      expect(dto.driverName, 'Roberto Silva');
      expect(dto.plate, 'BRA2E19');
      expect(dto.model, 'Ducato Maxi');
      expect(dto.shift, 'MORNING');

      final serialized = dto.toJson();
      expect(serialized['token'], 'van-1');
      expect(serialized['plate'], 'BRA2E19');
    });
  });

  group('AssistantLeanSignupRequestDto', () {
    test('serializes cleaning non-digit characters from cpf', () {
      const dto = AssistantLeanSignupRequestDto(
        inviteToken: 'inv-tok-99',
        name: ' Lucas Lima ',
        birthDate: '2000-01-15',
        email: ' lucas@example.com ',
        cpf: '123.456.789-00',
      );

      final json = dto.toJson();

      expect(json['inviteToken'], 'inv-tok-99');
      expect(json['name'], 'Lucas Lima');
      expect(json['birthDate'], '2000-01-15');
      expect(json['email'], 'lucas@example.com');
      expect(json['document'], '12345678900');
    });
  });
}
