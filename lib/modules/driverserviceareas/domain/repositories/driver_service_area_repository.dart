import '../../../../core/result/result.dart';
import '../entities/service_area.dart';
import '../entities/service_area_draft.dart';
import '../failures/service_area_failure.dart';

abstract class DriverServiceAreaRepository {
  Future<Result<ServiceAreaFailure, List<ServiceArea>>> findMyAreas();

  Future<Result<ServiceAreaFailure, List<ServiceArea>>> replaceMyAreas(
    List<ServiceAreaDraft> drafts,
  );
}
