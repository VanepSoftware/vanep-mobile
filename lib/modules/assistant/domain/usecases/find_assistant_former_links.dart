import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_vans_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_former_link.dart';

class FindAssistantFormerLinks {
  const FindAssistantFormerLinks(this.repository);

  final AssistantVansRepository repository;

  Future<Result<AssistantFailure, List<AssistantFormerLink>>> call() {
    return repository.findFormerLinks();
  }
}
