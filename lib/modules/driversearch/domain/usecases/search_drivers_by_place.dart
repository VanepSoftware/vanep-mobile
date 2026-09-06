import '../../../../core/result/result.dart';
import '../entities/driver_search_result.dart';
import '../failures/driver_search_failure.dart';
import '../repositories/driver_search_repository.dart';

class SearchDriversByPlace {
  const SearchDriversByPlace(this.repository);

  final DriverSearchRepository repository;

  Future<Result<DriverSearchFailure, List<DriverSearchResult>>> call(
    String placeId, {
    String? sessionToken,
  }) {
    return repository.searchByPlace(placeId, sessionToken);
  }
}
