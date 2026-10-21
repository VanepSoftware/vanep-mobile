import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';

class RemoveDependent {
  const RemoveDependent(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, void>> call(String token) {
    return repository.removeDependent(token);
  }
}
