import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/repositories/ibge_locations_repository.dart';

class ListCities {
  const ListCities(this.repository);

  final IbgeLocationsRepository repository;

  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>> call({
    required String uf,
    String? search,
    int page = 0,
    int size = 50,
  }) {
    return repository.listCities(
      uf: uf,
      search: search,
      page: page,
      size: size,
    );
  }
}
