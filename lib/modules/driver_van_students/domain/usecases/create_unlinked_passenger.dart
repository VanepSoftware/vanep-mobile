import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

class CreateUnlinkedPassenger {
  const CreateUnlinkedPassenger(this.repository);

  final DriverStudentRepository repository;

  Future<Result<DriverStudentFailure, String>> call(
    UnlinkedPassengerDraft draft,
  ) {
    return repository.createUnlinkedPassenger(draft);
  }
}
