import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';

import '../drivers_fixtures.dart';

void main() {
  test('parses the public profile with its vans', () {
    final profile = DriverProfileDto.fromJson(carlosProfileJson);

    expect(profile.name, 'Carlos Souza');
    expect(profile.phone, '61999990000');
    expect(profile.photoUrl, '/api/drivers/driver-1/photo');
    expect(profile.rating, 4.8);
    expect(profile.experienceYears, 8);
    expect(profile.available, isTrue);
    expect(profile.serviceAreas, ['Taguatinga', 'Ceilândia', 'Águas Claras']);
    expect(profile.vehicles, hasLength(1));
    expect(profile.vehicles.single.model, 'Sprinter');
    expect(profile.vehicles.single.manufactureYear, 2021);
    expect(
      profile.vehicles.single.photoFrontUrl,
      '/api/vehicles/van-1/photo-front',
    );
    expect(profile.vehicles.single.photoSideUrl, isNull);
  });

  test('defaults the lists and availability when they are absent', () {
    final profile = DriverProfileDto.fromJson(const {
      'token': 'driver-2',
      'name': 'Ana Pereira',
    });

    expect(profile.available, isFalse);
    expect(profile.serviceAreas, isEmpty);
    expect(profile.vehicles, isEmpty);
    expect(profile.phone, isNull);
  });
}
