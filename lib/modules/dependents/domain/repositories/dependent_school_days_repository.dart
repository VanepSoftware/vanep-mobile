import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';

abstract class DependentSchoolDaysRepository {
  Future<Result<DependentFailure, SchoolWeek>> findSchoolDays(
    String dependentToken,
  );

  Future<Result<DependentFailure, SchoolWeek>> replaceSchoolDays({
    required String dependentToken,
    required SchoolWeek week,
  });
}
