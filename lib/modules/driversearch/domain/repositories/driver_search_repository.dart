import '../../../../core/result/result.dart';
import '../entities/driver_search_result.dart';
import '../failures/driver_search_failure.dart';

abstract class DriverSearchRepository {
  Future<Result<DriverSearchFailure, List<DriverSearchResult>>> searchByPlace(
    String placeId,
    String? sessionToken,
  );
}
