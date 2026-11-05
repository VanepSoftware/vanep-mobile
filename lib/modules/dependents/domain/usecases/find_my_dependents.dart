import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/repositories/dependent_repository.dart';

class FindMyDependents {
  const FindMyDependents(this.repository);

  final DependentRepository repository;

  Future<Result<DependentFailure, List<Dependent>>> call() {
    return repository.findMyDependents();
  }
}
