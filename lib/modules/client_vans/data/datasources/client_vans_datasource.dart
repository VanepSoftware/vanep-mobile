import 'package:vanep_mobile/modules/client_vans/domain/entities/client_van.dart';

abstract class ClientVansDataSource {
  Future<List<ClientVan>> fetchMyVans();
}
