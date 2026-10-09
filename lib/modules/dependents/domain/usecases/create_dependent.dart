import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

class CreateDependent {
  const CreateDependent(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, Dependent>> call(DependentDraft draft) {
    return repository.createDependent(buildDependentChangesForCreate(draft));
  }
}
