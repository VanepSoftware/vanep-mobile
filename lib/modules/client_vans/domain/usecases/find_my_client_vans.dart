import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';
import 'package:vanep_mobile/modules/client_vans/domain/repositories/client_vans_repository.dart';

class FindMyClientVans {
  const FindMyClientVans(this.repository);

  final ClientVansRepository repository;

  Future<Result<ClientVansFailure, List<ClientVan>>> call() {
    return repository.findMyVans();
  }
}
