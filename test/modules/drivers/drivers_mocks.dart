import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/drivers/domain/repositories/driver_repository.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/list_recent_drivers.dart';

class MockDriverRepository extends Mock implements DriverRepository {}

class MockListRecentDrivers extends Mock implements ListRecentDrivers {}
