import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_school_days_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/data/datasources/dependent_remote_datasource.dart';
import 'package:vanep_mobile/modules/dependents/data/repositories/dependent_repository_impl.dart';

class DependentSchoolDaysRepositoryImpl
    implements DependentSchoolDaysRepository {
  const DependentSchoolDaysRepositoryImpl({required this.remote});

  final DependentRemoteDataSource remote;

  @override
  Future<Result<DependentFailure, SchoolWeek>> findSchoolDays(
    String dependentToken,
  ) {
    return guardDependentCall(() => remote.fetchSchoolDays(dependentToken));
  }

  @override
  Future<Result<DependentFailure, SchoolWeek>> replaceSchoolDays({
    required String dependentToken,
    required SchoolWeek week,
  }) {
    return guardDependentCall(
      () => remote.replaceSchoolDays(token: dependentToken, week: week),
    );
  }
}
