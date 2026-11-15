import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/list_van_assistants.dart';

import '../driver_van_central_fixtures.dart';
import '../driver_van_central_mocks.dart';

void main() {
  late MockVanCentralRepository repository;

  setUp(() => repository = MockVanCentralRepository());

  test('finds the driver occupancy', () async {
    when(() => repository.findOccupancy()).thenAnswer(
      (_) async => const Ok<VanCentralFailure, DriverOccupancy>(testOccupancy),
    );

    final result = await FindDriverOccupancy(repository)();

    expect(result.valueOrNull, testOccupancy);
  });

  test('finds whether the driver accepts new students', () async {
    when(() => repository.findAttendance()).thenAnswer(
      (_) async =>
          const Ok<VanCentralFailure, DriverAttendance>(testAttendance),
    );

    final result = await FindDriverAttendance(repository)();

    expect(result.valueOrNull, testAttendance);
  });

  test('stops accepting new students', () async {
    const closed = TestDriverAttendance(acceptingStudents: false);
    when(() => repository.changeAcceptingStudents(false)).thenAnswer(
      (_) async => const Ok<VanCentralFailure, DriverAttendance>(closed),
    );

    final result = await ChangeAcceptingStudents(repository)(
      acceptingStudents: false,
    );

    expect(result.valueOrNull, closed);
    verify(() => repository.changeAcceptingStudents(false)).called(1);
  });

  test('lists the van assistants and passes failures through', () async {
    when(() => repository.listAssistants()).thenAnswer(
      (_) async => const Err<VanCentralFailure, List<VanAssistant>>(
        VanCentralFailure.network,
      ),
    );

    final result = await ListVanAssistants(repository)();

    expect(result.errorOrNull, VanCentralFailure.network);
  });
}
