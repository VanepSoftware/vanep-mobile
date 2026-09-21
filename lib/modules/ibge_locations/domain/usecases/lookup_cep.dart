import '../../../../core/result/result.dart';
import '../entities/cep_lookup.dart';
import '../failures/cep_failure.dart';
import '../repositories/ibge_locations_repository.dart';

class LookupCep {
  const LookupCep(this.repository);

  final IbgeLocationsRepository repository;

  Future<Result<CepFailure, CepLookup>> call(String cep) {
    return repository.lookupCep(cep);
  }
}
