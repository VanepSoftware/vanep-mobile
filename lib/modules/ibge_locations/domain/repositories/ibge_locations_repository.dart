import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';

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
