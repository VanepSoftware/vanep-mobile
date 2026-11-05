import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

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
