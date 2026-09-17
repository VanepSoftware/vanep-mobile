import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/repositories/driver_service_area_repository.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/find_my_service_areas.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/replace_my_service_areas.dart';

class MockDriverServiceAreaRepository extends Mock
    implements DriverServiceAreaRepository {}

class MockFindMyServiceAreas extends Mock implements FindMyServiceAreas {}

class MockReplaceMyServiceAreas extends Mock implements ReplaceMyServiceAreas {}
