import '../../../../core/result/result.dart';
import '../entities/dependent.dart';
import '../failures/dependent_failure.dart';
import '../repositories/dependent_repository.dart';

class SetDefaultDependent {
  const SetDefaultDependent(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, Dependent>> call(String token) {
    return repository.markAsDefault(token);
  }
}
