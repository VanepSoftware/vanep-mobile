import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';

class FindParentsGroupInvite {
  const FindParentsGroupInvite(this.repository);

  final DriverStudentRepository repository;

  Future<Result<DriverStudentFailure, FamilyInvite>> call() {
    return repository.findParentsGroupInvite();
  }
}
