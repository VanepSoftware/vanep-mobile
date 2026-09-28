import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_state.dart';

import '../drivers_fixtures.dart';
import '../drivers_mocks.dart';

void main() {
  late MockFindDriverProfile findDriverProfile;

  setUp(() => findDriverProfile = MockFindDriverProfile());

  DriverProfileCubit buildCubit() => DriverProfileCubit(
    findDriverProfile: findDriverProfile,
    driverToken: 'driver-1',
  );

  test('starts loading', () {
    expect(buildCubit().state, const DriverProfileState());
  });

  blocTest<DriverProfileCubit, DriverProfileState>(
    'emits the profile of the chosen driver',
    setUp: () => when(() => findDriverProfile('driver-1')).thenAnswer(
      (_) async => const Ok<DriverFailure, DriverProfile>(testDriverProfile),
    ),
    build: buildCubit,
    act: (cubit) => cubit.loadProfile(),
    expect: () => const [
      DriverProfileState(),
      DriverProfileState(
        status: DriverProfileStatus.loaded,
        profile: testDriverProfile,
      ),
    ],
  );

  blocTest<DriverProfileCubit, DriverProfileState>(
    'emits the failure when the driver cannot be loaded',
    setUp: () => when(() => findDriverProfile('driver-1')).thenAnswer(
      (_) async =>
          const Err<DriverFailure, DriverProfile>(NotFoundDriverFailure()),
    ),
    build: buildCubit,
    act: (cubit) => cubit.loadProfile(),
    expect: () => const [
      DriverProfileState(),
      DriverProfileState(
        status: DriverProfileStatus.error,
        failure: NotFoundDriverFailure(),
      ),
    ],
  );
}
