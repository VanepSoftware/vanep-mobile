import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';

abstract class DriverSearchRepository {
  Future<Result<DriverSearchFailure, DriverSearchPage>> searchByPlace(
    String placeId,
    String? sessionToken, {
    int page,
  });
}
