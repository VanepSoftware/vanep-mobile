import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/repositories/school_repository.dart';

class ResolveSchool {
  const ResolveSchool(this.repository);

  final SchoolRepository repository;

  Future<Result<SchoolFailure, School>> call({
    required String placeId,
    required String sessionToken,
  }) {
    return repository.resolveSchool(
      placeId: placeId,
      sessionToken: sessionToken,
    );
  }
}
