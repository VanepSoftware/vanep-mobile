import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/repositories/ibge_locations_repository.dart';

class LookupCep {
  const LookupCep(this.repository);

  final IbgeLocationsRepository repository;

  Future<Result<CepFailure, CepLookup>> call(String cep) {
    return repository.lookupCep(cep);
  }
}
