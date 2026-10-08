import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';

class GetLinkedVans {
  const GetLinkedVans(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, List<AssistantVan>>> call() {
    return repository.getLinkedVans();
  }
}
