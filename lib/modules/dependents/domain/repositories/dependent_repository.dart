import '../../../../core/result/result.dart';
import '../entities/dependent.dart';
import '../failures/dependent_failure.dart';
import '../value_objects/dependent_changes.dart';

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
