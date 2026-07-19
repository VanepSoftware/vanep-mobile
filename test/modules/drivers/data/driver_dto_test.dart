import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_dto.dart';

import '../drivers_fixtures.dart';

void main() {
  test('fromJson maps every field including the photo key', () {
    final dto = DriverDto.fromJson(carlosJson);

    expect(dto.token, 'driver-1');
    expect(dto.name, 'Carlos Souza');
    expect(dto.photoUrl, 'https://cdn.vanep.com/carlos.jpg');
    expect(dto.rating, 4.8);
    expect(dto.experienceYears, 8);
    expect(dto.city, 'Taguatinga');
  });

  test('fromJson tolerates missing optional fields', () {
    final dto = DriverDto.fromJson({
      'token': 'driver-3',
      'name': 'Ricardo Lima',
    });

    expect(dto.photoUrl, isNull);
    expect(dto.rating, isNull);
    expect(dto.experienceYears, isNull);
    expect(dto.city, isNull);
  });
}
