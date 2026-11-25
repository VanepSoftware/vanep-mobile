import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_vans/domain/repositories/client_vans_repository.dart';
import 'package:vanep_mobile/modules/client_vans/domain/usecases/find_my_client_vans.dart';

class MockClientVansRepository extends Mock implements ClientVansRepository {}

class MockFindMyClientVans extends Mock implements FindMyClientVans {}
