import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';

class UndoStopConfirmation {
  const UndoStopConfirmation(this.repository);

  final AssistantRouteRepository repository;

  Future<Result<AssistantFailure, AssistantRouteSnapshot>> call({
    required String vanToken,
    required String stopToken,
  }) {
    return repository.undoStopConfirmation(
      vanToken: vanToken,
      stopToken: stopToken,
    );
  }
}
