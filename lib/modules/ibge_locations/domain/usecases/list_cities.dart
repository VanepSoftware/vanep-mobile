import '../../../../core/result/result.dart';
import '../entities/brazilian_city.dart';
import '../entities/ibge_locations_page.dart';
import '../failures/ibge_locations_failure.dart';
import '../repositories/ibge_locations_repository.dart';

class ListCities {
  const ListCities(this.repository);

  final IbgeLocationsRepository repository;

  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>> call({
    required String uf,
    String? search,
    int page = 0,
    int size = 20,
  }) {
    return repository.listCities(
      uf: uf,
      search: search,
      page: page,
      size: size,
    );
  }
}
