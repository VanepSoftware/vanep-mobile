import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/driver_professional_data/presentation/cubit/professional_data_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/profile/domain/failures/profile_summary_failure.dart';
import 'package:vanep_mobile/modules/profile/domain/usecases/get_profile_summary.dart';

import '../driver_van_central/driver_van_central_fixtures.dart';
import '../driver_van_central/driver_van_central_mocks.dart';
import '../profile/profile_fixtures.dart';
import '../profile/profile_mocks.dart';

void main() {
  late MockProfileSummaryRepository profiles;
  late MockVanCentralRepository central;

  setUp(() {
    profiles = MockProfileSummaryRepository();
    central = MockVanCentralRepository();
  });

  ProfessionalDataCubit build() => ProfessionalDataCubit(
    getProfileSummary: GetProfileSummary(profiles),
    findDriverAttendance: FindDriverAttendance(central),
    changeAcceptingStudents: ChangeAcceptingStudents(central),
  );

  void stubProfile() =>
      when(() => profiles.fetchSummary(UserType.driver))
          .thenAnswer((_) async => const Ok(testDriverSummaryDto));

  void stubAttendance() =>
      when(central.findAttendance)
          .thenAnswer((_) async => const Ok(testAttendance));

  blocTest<ProfessionalDataCubit, ProfessionalDataState>(
    'loads the driver profile and the attendance',
    setUp: () {
      stubProfile();
      stubAttendance();
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [
      ProfessionalDataState(),
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: testDriverSummaryDto,
        attendance: testAttendance,
      ),
    ],
  );

  blocTest<ProfessionalDataCubit, ProfessionalDataState>(
    'a failed profile fails the screen',
    setUp: () {
      when(() => profiles.fetchSummary(UserType.driver))
          .thenAnswer((_) async => const Err(NetworkProfileSummaryFailure()));
      stubAttendance();
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [
      ProfessionalDataState(),
      ProfessionalDataState(status: ProfessionalDataStatus.failed),
    ],
  );

  blocTest<ProfessionalDataCubit, ProfessionalDataState>(
    'a failed attendance keeps the screen without the switch',
    setUp: () {
      stubProfile();
      when(central.findAttendance)
          .thenAnswer((_) async => const Err(VanCentralFailure.network));
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => const [
      ProfessionalDataState(),
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: testDriverSummaryDto,
      ),
    ],
  );

  blocTest<ProfessionalDataCubit, ProfessionalDataState>(
    'turning new students off follows the same rule of the van central',
    setUp: () => when(() => central.changeAcceptingStudents(false)).thenAnswer(
      (_) async => const Ok(TestDriverAttendance(acceptingStudents: false)),
    ),
    build: build,
    seed: () => const ProfessionalDataState(
      status: ProfessionalDataStatus.ready,
      summary: testDriverSummaryDto,
      attendance: testAttendance,
    ),
    act: (cubit) => cubit.setAcceptingStudents(false),
    expect: () => const [
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: testDriverSummaryDto,
        attendance: testAttendance,
        isChangingAttendance: true,
      ),
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: testDriverSummaryDto,
        attendance: TestDriverAttendance(acceptingStudents: false),
      ),
    ],
  );

  blocTest<ProfessionalDataCubit, ProfessionalDataState>(
    'a failed change keeps the switch and tells the driver',
    setUp: () =>
        when(() => central.changeAcceptingStudents(false))
            .thenAnswer((_) async => const Err(VanCentralFailure.network)),
    build: build,
    seed: () => const ProfessionalDataState(
      status: ProfessionalDataStatus.ready,
      summary: testDriverSummaryDto,
      attendance: testAttendance,
    ),
    act: (cubit) => cubit.setAcceptingStudents(false),
    skip: 1,
    expect: () => const [
      ProfessionalDataState(
        status: ProfessionalDataStatus.ready,
        summary: testDriverSummaryDto,
        attendance: testAttendance,
        attendanceChangeFailed: true,
      ),
    ],
  );
}
