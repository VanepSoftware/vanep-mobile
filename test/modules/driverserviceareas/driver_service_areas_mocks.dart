import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/repositories/driver_service_area_repository.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/usecases/find_my_service_areas.dart';
import 'package:vanep_mobile/modules/driverserviceareas/domain/usecases/replace_my_service_areas.dart';

class MockDriverServiceAreaRepository extends Mock
    implements DriverServiceAreaRepository {}

class MockFindMyServiceAreas extends Mock implements FindMyServiceAreas {}

class MockReplaceMyServiceAreas extends Mock implements ReplaceMyServiceAreas {}
