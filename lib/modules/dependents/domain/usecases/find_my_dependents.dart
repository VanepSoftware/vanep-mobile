import '../../../../core/result/result.dart';
import '../entities/dependent.dart';
import '../failures/dependent_failure.dart';
import '../repositories/dependent_repository.dart';

class FindMyDependents {
  const FindMyDependents(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, List<Dependent>>> call() {
    return repository.findMyDependents();
  }
}
