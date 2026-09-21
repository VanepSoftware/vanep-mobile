import '../../../../core/result/result.dart';
import '../entities/brazilian_city.dart';
import '../entities/brazilian_state.dart';
import '../entities/cep_lookup.dart';
import '../entities/ibge_locations_page.dart';
import '../failures/cep_failure.dart';
import '../failures/ibge_locations_failure.dart';

abstract class IbgeLocationsRepository {
  Future<Result<CepFailure, CepLookup>> lookupCep(String cep);

  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianState>>>
  listStates({required int page, required int size});

  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>>
  listCities({
    required String uf,
    String? search,
    required int page,
    required int size,
  });
}
