import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_school_days_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';

class FindSchoolDays {
  const FindSchoolDays(this.repository);

  final DependentSchoolDaysRepository repository;

  Future<Result<DependentFailure, SchoolWeek>> call(String dependentToken) {
    return repository.findSchoolDays(dependentToken);
  }
}
