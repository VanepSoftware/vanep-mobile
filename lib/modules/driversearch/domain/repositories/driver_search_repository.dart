import '../../../../core/result/result.dart';
import '../entities/driver_search_page.dart';
import '../failures/driver_search_failure.dart';

abstract class DriverSearchRepository {
  Future<Result<DriverSearchFailure, DriverSearchPage>> searchByPlace(
    String placeId,
    String? sessionToken, {
    int page,
  });
}
