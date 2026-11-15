import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';

class DismissStudentFamilyMatch {
  const DismissStudentFamilyMatch(this.repository);

  final DriverStudentRepository repository;

  Future<Result<DriverStudentFailure, void>> call(String studentToken) {
    return repository.dismissFamilyMatch(studentToken);
  }
}
