import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';

abstract class SchoolRepository {
  Future<Result<SchoolFailure, School>> resolveSchool({
    required String placeId,
    required String sessionToken,
  });
}
