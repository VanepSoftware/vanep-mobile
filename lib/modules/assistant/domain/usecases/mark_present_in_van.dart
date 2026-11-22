import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';

class MarkPresentInVan {
  const MarkPresentInVan(this.repository);

  final AssistantRouteRepository repository;

  Future<Result<AssistantFailure, void>> call(String vanToken) {
    return repository.markPresentInVan(vanToken);
  }
}
