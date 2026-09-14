import '../../../../core/result/result.dart';
import '../entities/dependent.dart';
import '../failures/dependent_failure.dart';
import '../repositories/dependent_repository.dart';
import '../value_objects/dependent_changes.dart';
import '../value_objects/dependent_draft.dart';

class CreateDependent {
  const CreateDependent(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, Dependent>> call(DependentDraft draft) {
    return repository.createDependent(buildDependentChangesForCreate(draft));
  }
}
