import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';
import 'package:vanep_mobile/modules/client_vans/domain/failures/client_vans_failure.dart';

abstract class ClientVansRepository {
  Future<Result<ClientVansFailure, List<ClientVan>>> findMyVans();
}
