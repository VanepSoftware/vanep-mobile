import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';

abstract class DependentRepository {
  Future<Result<DependentFailure, List<Dependent>>> findMyDependents();

  Future<Result<DependentFailure, Dependent>> createDependent(
    DependentChanges changes,
  );

  Future<Result<DependentFailure, Dependent>> updateDependent({
    required String token,
    required DependentChanges changes,
  });

  Future<Result<DependentFailure, Dependent>> markAsDefault(String token);
}
