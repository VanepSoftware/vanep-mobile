import '../../../../core/result/result.dart';
import '../entities/assistant_van.dart';
import '../failures/assistant_failure.dart';
import '../repositories/assistant_repository.dart';

class GetLinkedVans {
  const GetLinkedVans(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, List<AssistantVan>>> call() {
    return repository.getLinkedVans();
  }
}
