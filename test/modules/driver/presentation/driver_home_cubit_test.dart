import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';

void main() {
  group('DriverHomeCubit', () {
    blocTest<DriverHomeCubit, DriverHomeState>(
      'seedToday sets the shift start time',
      build: DriverHomeCubit.new,
      act: (cubit) => cubit.seedToday(shiftStartTime: '6h00'),
      expect: () => const [DriverHomeState(shiftStartTime: '6h00')],
    );

    blocTest<DriverHomeCubit, DriverHomeState>(
      'startRoute puts the driver on shift',
      build: DriverHomeCubit.new,
      act: (cubit) => cubit.startRoute(),
      expect: () => const [DriverHomeState(shift: DriverShift.on)],
    );

    blocTest<DriverHomeCubit, DriverHomeState>(
      'endRoute puts the driver off shift',
      build: DriverHomeCubit.new,
      seed: () => const DriverHomeState(shift: DriverShift.on),
      act: (cubit) => cubit.endRoute(),
      expect: () => const [DriverHomeState()],
    );

    blocTest<DriverHomeCubit, DriverHomeState>(
      'setLocationSharing toggles location sharing on',
      build: DriverHomeCubit.new,
      act: (cubit) => cubit.setLocationSharing(true),
      expect: () => const [DriverHomeState(sharingLocation: true)],
    );
  });
}
