import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driver_search/domain/repositories/driver_search_repository.dart';

class SearchDriversByPlace {
  const SearchDriversByPlace(this.repository);

  final DriverSearchRepository repository;

  Future<Result<DriverSearchFailure, DriverSearchPage>> call(
    String placeId, {
    String? sessionToken,
    int page = 0,
  }) {
    return repository.searchByPlace(placeId, sessionToken, page: page);
  }
}
