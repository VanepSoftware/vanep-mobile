import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/repositories/ibge_locations_repository.dart';

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
