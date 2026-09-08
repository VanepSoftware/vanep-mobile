import '../../../../core/result/result.dart';
import '../entities/service_area.dart';
import '../entities/service_area_draft.dart';
import '../failures/service_area_failure.dart';
import '../repositories/driver_service_area_repository.dart';

const maxServiceAreas = 10;

class ReplaceMyServiceAreas {
  const ReplaceMyServiceAreas(this.repository);

  final DriverServiceAreaRepository repository;

  Future<Result<ServiceAreaFailure, List<ServiceArea>>> call(
    List<ServiceAreaDraft> drafts,
  ) {
    if (drafts.length > maxServiceAreas) {
      return Future.value(const Err(ServiceAreaFailure.tooManyAreas));
    }
    return repository.replaceMyAreas(drafts);
  }
}
