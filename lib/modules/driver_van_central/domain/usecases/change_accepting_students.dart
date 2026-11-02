import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/repositories/van_central_repository.dart';

class ChangeAcceptingStudents {
  const ChangeAcceptingStudents(this.repository);

  final VanCentralRepository repository;

  Future<Result<VanCentralFailure, DriverAttendance>> call({
    required bool acceptingStudents,
  }) {
    return repository.changeAcceptingStudents(acceptingStudents);
  }
}
