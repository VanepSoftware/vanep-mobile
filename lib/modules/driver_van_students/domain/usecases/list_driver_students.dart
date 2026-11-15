import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';

class ListDriverStudents {
  const ListDriverStudents(this.repository);

  final DriverStudentRepository repository;

  Future<Result<DriverStudentFailure, List<DriverStudent>>> call({
    String? vehicleToken,
  }) {
    return repository.listStudents(vehicleToken: vehicleToken);
  }
}
