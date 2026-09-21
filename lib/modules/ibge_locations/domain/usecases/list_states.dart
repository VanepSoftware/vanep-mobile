import '../../../../core/result/result.dart';
import '../entities/brazilian_state.dart';
import '../entities/ibge_locations_page.dart';
import '../failures/ibge_locations_failure.dart';
import '../repositories/ibge_locations_repository.dart';

class ListStates {
  const ListStates(this.repository);

  final IbgeLocationsRepository repository;

  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianState>>> call({
    int page = 0,
    int size = 30,
  }) {
    return repository.listStates(page: page, size: size);
  }
}
