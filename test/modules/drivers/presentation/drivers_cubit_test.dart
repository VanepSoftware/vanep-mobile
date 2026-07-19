import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';

import '../drivers_fixtures.dart';
import '../drivers_mocks.dart';

void main() {
  late MockListRecentDrivers listRecentDrivers;

  setUp(() => listRecentDrivers = MockListRecentDrivers());

  DriversCubit buildCubit() =>
      DriversCubit(listRecentDrivers: listRecentDrivers);

  group('loadRecentDrivers', () {
    blocTest<DriversCubit, DriversState>(
      'emits loading then loaded with drivers on success',
      setUp: () => when(() => listRecentDrivers()).thenAnswer(
        (_) async => const Ok<DriverFailure, List<Driver>>(testRecentDrivers),
      ),
      build: buildCubit,
      act: (cubit) => cubit.loadRecentDrivers(),
      expect: () => const [
        DriversState(status: DriversStatus.loading),
        DriversState(
          status: DriversStatus.loaded,
          drivers: testRecentDrivers,
        ),
      ],
    );

    blocTest<DriversCubit, DriversState>(
      'emits loading then error on failure',
      setUp: () => when(() => listRecentDrivers()).thenAnswer(
        (_) async =>
            const Err<DriverFailure, List<Driver>>(NetworkDriverFailure()),
      ),
      build: buildCubit,
      act: (cubit) => cubit.loadRecentDrivers(),
      expect: () => const [
        DriversState(status: DriversStatus.loading),
        DriversState(
          status: DriversStatus.error,
          failure: NetworkDriverFailure(),
        ),
      ],
    );
  });

  blocTest<DriversCubit, DriversState>(
    'search stores the query',
    build: buildCubit,
    act: (cubit) => cubit.search('carlos'),
    expect: () => const [DriversState(query: 'carlos')],
  );
}
