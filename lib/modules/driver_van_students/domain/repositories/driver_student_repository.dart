import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

abstract class DriverStudentRepository {
  Future<Result<DriverStudentFailure, List<DriverStudent>>> listStudents({
    String? vehicleToken,
  });

  Future<Result<DriverStudentFailure, FamilyInvite>> inviteFamily(
    String studentToken,
  );

  Future<Result<DriverStudentFailure, FamilyInvite>> findParentsGroupInvite();

  Future<Result<DriverStudentFailure, void>> mergeFamily(String studentToken);

  Future<Result<DriverStudentFailure, void>> dismissFamilyMatch(
    String studentToken,
  );

  Future<Result<DriverStudentFailure, String>> createUnlinkedPassenger(
    UnlinkedPassengerDraft draft,
  );
}
