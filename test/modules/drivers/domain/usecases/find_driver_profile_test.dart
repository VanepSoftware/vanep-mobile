import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/find_driver_profile.dart';

import '../../drivers_fixtures.dart';
import '../../drivers_mocks.dart';

void main() {
  test('asks the repository for the profile of the chosen driver', () async {
    final repository = MockDriverRepository();
    when(() => repository.findProfile('driver-1')).thenAnswer(
      (_) async => const Ok<DriverFailure, DriverProfile>(testDriverProfile),
    );

    final result = await FindDriverProfile(repository)('driver-1');

    expect(result.valueOrNull, testDriverProfile);
    verify(() => repository.findProfile('driver-1')).called(1);
  });
}
