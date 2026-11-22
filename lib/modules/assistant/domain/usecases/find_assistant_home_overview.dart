import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';

class FindAssistantHomeOverview {
  const FindAssistantHomeOverview(this.repository);

  final AssistantRouteRepository repository;

  Future<Result<AssistantFailure, AssistantHomeOverview>> call() {
    return repository.findHomeOverview();
  }
}
