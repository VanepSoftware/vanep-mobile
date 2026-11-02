import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';

import '../driver_van_central_fixtures.dart';
import '../driver_van_central_mocks.dart';

void main() {
  late VanCentralUseCaseMocks mocks;

  setUp(() => mocks = VanCentralUseCaseMocks());

  VanCentralCubit buildCubit() => mocks.buildCubit();

  blocTest<VanCentralCubit, VanCentralState>(
    'loads the vans and everything around them, selecting the first van',
    setUp: () => mocks.stubAll(),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => const [VanCentralState(), loadedCentral],
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'without vans the central is loaded and empty',
    setUp: () => mocks.stubAll(vans: const []),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, VanCentralStatus.loaded);
      expect(cubit.state.hasVans, isFalse);
      expect(cubit.state.selectedVan, isNull);
    },
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'a failed van list fails the whole load',
    setUp: () {
      mocks.stubAll();
      when(() => mocks.listMyVans()).thenAnswer(
        (_) async => const Err<DriverVanFailure, List<DriverVan>>(
          DriverVanFailure.network,
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => const [
      VanCentralState(),
      VanCentralState(status: VanCentralStatus.loadFailed),
    ],
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'the rest of the central degrades when its side data fails',
    setUp: () {
      mocks.stubAll();
      when(() => mocks.findDriverOccupancy()).thenAnswer(
        (_) async => const Err<VanCentralFailure, DriverOccupancy>(
          VanCentralFailure.network,
        ),
      );
      when(() => mocks.findMyServiceAreas()).thenAnswer(
        (_) async => const Err<ServiceAreaFailure, List<ServiceArea>>(
          ServiceAreaFailure.network,
        ),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, VanCentralStatus.loaded);
      expect(cubit.state.occupancy, isNull);
      expect(cubit.state.serviceAreas, isNull);
      expect(cubit.state.attendance, testAttendance);
    },
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'keeps the selected van across a refresh, or falls back to the first',
    setUp: () => mocks.stubAll(vans: [secondVan]),
    build: buildCubit,
    seed: () => loadedCentral.copyWith(selectedVanToken: 'van-2'),
    act: (cubit) => cubit.refresh(),
    verify: (cubit) => expect(cubit.state.selectedVanToken, 'van-2'),
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'a van that is gone gives the selection back to the first van',
    setUp: () => mocks.stubAll(vans: [firstVan]),
    build: buildCubit,
    seed: () => loadedCentral.copyWith(selectedVanToken: 'van-2'),
    act: (cubit) => cubit.refresh(),
    verify: (cubit) => expect(cubit.state.selectedVanToken, 'van-1'),
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'selects another van',
    build: buildCubit,
    seed: () => loadedCentral,
    act: (cubit) => cubit.selectVan('van-2'),
    expect: () => [loadedCentral.copyWith(selectedVanToken: 'van-2')],
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'stops accepting new students',
    setUp: () =>
        when(
          () => mocks.changeAcceptingStudents(acceptingStudents: false),
        ).thenAnswer(
          (_) async =>
              const Ok<VanCentralFailure, DriverAttendance>(closedAttendance),
        ),
    build: buildCubit,
    seed: () => loadedCentral,
    act: (cubit) => cubit.setAcceptingStudents(false),
    expect: () => [
      loadedCentral.copyWith(isChangingAttendance: true),
      loadedCentral.copyWith(attendance: closedAttendance),
    ],
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'a failed change keeps the old value and tells the driver',
    setUp: () =>
        when(() => mocks.changeAcceptingStudents(acceptingStudents: false))
            .thenAnswer(
              (_) async => const Err<VanCentralFailure, DriverAttendance>(
                VanCentralFailure.network,
              ),
            ),
    build: buildCubit,
    seed: () => loadedCentral,
    act: (cubit) => cubit.setAcceptingStudents(false),
    expect: () => [
      loadedCentral.copyWith(isChangingAttendance: true),
      loadedCentral.copyWith(notice: const AttendanceChangeFailedNotice()),
    ],
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'ignores a second change while one is running',
    build: buildCubit,
    seed: () => loadedCentral.copyWith(isChangingAttendance: true),
    act: (cubit) => cubit.setAcceptingStudents(false),
    expect: () => const <VanCentralState>[],
    verify: (_) => verifyNever(
      () => mocks.changeAcceptingStudents(
        acceptingStudents: any(named: 'acceptingStudents'),
      ),
    ),
  );

  blocTest<VanCentralCubit, VanCentralState>(
    'clears a notice once shown',
    build: buildCubit,
    seed: () =>
        loadedCentral.copyWith(notice: const AttendanceChangeFailedNotice()),
    act: (cubit) => cubit.clearNotice(),
    expect: () => [loadedCentral],
  );

  test('the selected van is looked up by its token', () {
    expect(loadedCentral.selectedVan, firstVan);
    expect(
      loadedCentral.copyWith(selectedVanToken: 'van-2').selectedVan,
      secondVan,
    );
    expect(
      loadedCentral.copyWith(selectedVanToken: 'missing').selectedVan,
      firstVan,
    );
  });

  test('the team is working when an assistant is active', () {
    expect(loadedCentral.hasWorkingAssistant, isTrue);
    expect(
      loadedCentral.copyWith(assistants: const []).hasWorkingAssistant,
      isFalse,
    );
  });
}

const loadedCentral = VanCentralState(
  status: VanCentralStatus.loaded,
  vans: [firstVan, secondVan],
  selectedVanToken: 'van-1',
  occupancy: testOccupancy,
  attendance: testAttendance,
  assistants: testAssistants,
  serviceAreas: testServiceAreas,
);

const closedAttendance = TestDriverAttendance(acceptingStudents: false);
