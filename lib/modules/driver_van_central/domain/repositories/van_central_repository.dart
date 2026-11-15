import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';

abstract class VanCentralRepository {
  Future<Result<VanCentralFailure, DriverOccupancy>> findOccupancy();

  Future<Result<VanCentralFailure, DriverAttendance>> findAttendance();

  Future<Result<VanCentralFailure, DriverAttendance>> changeAcceptingStudents(
    bool acceptingStudents,
  );

  Future<Result<VanCentralFailure, List<VanAssistant>>> listAssistants();
}
