import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

abstract class AssistantRouteRepository {
  Future<Result<AssistantFailure, AssistantHomeOverview>> findHomeOverview();

  Future<Result<AssistantFailure, AssistantRouteSnapshot?>> findTodayRoute(
    String vanToken,
  );

  Future<Result<AssistantFailure, AssistantRouteSnapshot>> confirmStop(
    StopConfirmation confirmation,
  );

  Future<Result<AssistantFailure, AssistantRouteSnapshot>>
  undoStopConfirmation({required String vanToken, required String stopToken});

  Future<Result<AssistantFailure, void>> markPresentInVan(String vanToken);
}
