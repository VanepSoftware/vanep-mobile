import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_route_repository.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

class AssistantRouteRepositoryImpl implements AssistantRouteRepository {
  const AssistantRouteRepositoryImpl({required this.dataSource});

  final AssistantRouteDataSource dataSource;

  @override
  Future<Result<AssistantFailure, AssistantHomeOverview>>
  findHomeOverview() async {
    return Ok(await dataSource.findHomeOverview());
  }

  @override
  Future<Result<AssistantFailure, AssistantRouteSnapshot?>> findTodayRoute(
    String vanToken,
  ) async {
    return Ok(await dataSource.findTodayRoute(vanToken));
  }

  @override
  Future<Result<AssistantFailure, AssistantRouteSnapshot>> confirmStop(
    StopConfirmation confirmation,
  ) async {
    return Ok(await dataSource.confirmStop(confirmation));
  }

  @override
  Future<Result<AssistantFailure, AssistantRouteSnapshot>>
  undoStopConfirmation({
    required String vanToken,
    required String stopToken,
  }) async {
    return Ok(
      await dataSource.undoStopConfirmation(
        vanToken: vanToken,
        stopToken: stopToken,
      ),
    );
  }

  @override
  Future<Result<AssistantFailure, void>> markPresentInVan(
    String vanToken,
  ) async {
    await dataSource.markPresentInVan(vanToken);
    return const Ok(null);
  }
}
