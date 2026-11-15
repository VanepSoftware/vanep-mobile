import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';

class FindAssistantTodayRoute {
  const FindAssistantTodayRoute(this.repository);

  final AssistantRouteRepository repository;

  Future<Result<AssistantFailure, AssistantRouteSnapshot?>> call(
    String vanToken,
  ) {
    return repository.findTodayRoute(vanToken);
  }
}
