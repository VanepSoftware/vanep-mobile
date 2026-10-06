import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area_draft.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';

abstract class DriverServiceAreaRepository {
  Future<Result<ServiceAreaFailure, List<ServiceArea>>> findMyAreas();

  Future<Result<ServiceAreaFailure, List<ServiceArea>>> replaceMyAreas(
    List<ServiceAreaDraft> drafts,
  );
}
