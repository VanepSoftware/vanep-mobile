import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/find_my_service_areas.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/datasources/van_central_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/failures/van_central_failure.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/repositories/van_central_repository.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/list_van_assistants.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';

import 'driver_van_central_fixtures.dart';

class MockDio extends Mock implements Dio {}

class MockVanCentralRemoteDataSource extends Mock
    implements VanCentralRemoteDataSource {}

class MockVanCentralRepository extends Mock implements VanCentralRepository {}

class MockListMyVans extends Mock implements ListMyVans {}

class MockFindMyServiceAreas extends Mock implements FindMyServiceAreas {}

class MockFindDriverOccupancy extends Mock implements FindDriverOccupancy {}

class MockFindDriverAttendance extends Mock implements FindDriverAttendance {}

class MockChangeAcceptingStudents extends Mock
    implements ChangeAcceptingStudents {}

class MockListVanAssistants extends Mock implements ListVanAssistants {}

class MockVanCentralCubit extends MockCubit<VanCentralState>
    implements VanCentralCubit {}

class VanCentralUseCaseMocks {
  final listMyVans = MockListMyVans();
  final findMyServiceAreas = MockFindMyServiceAreas();
  final findDriverOccupancy = MockFindDriverOccupancy();
  final findDriverAttendance = MockFindDriverAttendance();
  final changeAcceptingStudents = MockChangeAcceptingStudents();
  final listVanAssistants = MockListVanAssistants();

  VanCentralCubit buildCubit() => VanCentralCubit(
    listMyVans: listMyVans,
    findMyServiceAreas: findMyServiceAreas,
    findDriverOccupancy: findDriverOccupancy,
    findDriverAttendance: findDriverAttendance,
    changeAcceptingStudents: changeAcceptingStudents,
    listVanAssistants: listVanAssistants,
  );

  void stubAll({List<DriverVan> vans = const [firstVan, secondVan]}) {
    when(() => listMyVans())
        .thenAnswer((_) async => Ok<DriverVanFailure, List<DriverVan>>(vans));
    when(() => findMyServiceAreas()).thenAnswer(
      (_) async =>
          const Ok<ServiceAreaFailure, List<ServiceArea>>(testServiceAreas),
    );
    when(() => findDriverOccupancy()).thenAnswer(
      (_) async => const Ok<VanCentralFailure, DriverOccupancy>(testOccupancy),
    );
    when(() => findDriverAttendance()).thenAnswer(
      (_) async =>
          const Ok<VanCentralFailure, DriverAttendance>(testAttendance),
    );
    when(() => listVanAssistants()).thenAnswer(
      (_) async =>
          const Ok<VanCentralFailure, List<VanAssistant>>(testAssistants),
    );
  }
}
