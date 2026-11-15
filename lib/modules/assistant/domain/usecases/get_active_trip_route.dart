import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_trip_stop.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/repositories/assistant_repository.dart';

class GetActiveTripRoute {
  const GetActiveTripRoute(this.repository);

  final AssistantRepository repository;

  Future<Result<AssistantFailure, List<AssistantTripStop>>> call(
    String vanToken,
  ) {
    return repository.getActiveTripRoute(vanToken);
  }
}
