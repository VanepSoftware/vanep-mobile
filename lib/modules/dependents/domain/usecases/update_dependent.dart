import '../../../../core/result/result.dart';
import '../entities/dependent.dart';
import '../failures/dependent_failure.dart';
import '../repositories/dependent_repository.dart';
import '../value_objects/dependent_changes.dart';
import '../value_objects/dependent_draft.dart';

class UpdateDependent {
  const UpdateDependent(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, Dependent>?> call({
    required Dependent snapshot,
    required DependentDraft draft,
  }) {
    final changes = buildDependentChangesForUpdate(
      draft: draft,
      snapshot: snapshot,
    );
    if (changes.isEmpty) return Future.value(null);
    return repository.updateDependent(
      token: snapshot.token,
      changes: changes,
    );
  }
}
