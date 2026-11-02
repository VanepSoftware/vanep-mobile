import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/find_my_service_areas.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/datasources/van_central_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/repositories/van_central_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/repositories/van_central_repository.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/change_accepting_students.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/find_driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/usecases/list_van_assistants.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/usecases/list_my_vans.dart';

void registerDriverVanCentralDependencies(GetIt getIt) {
  getIt
    ..registerSingleton<VanCentralRemoteDataSource>(
      VanCentralRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: getIt<Environment>(),
      ),
    )
    ..registerSingleton<VanCentralRepository>(
      VanCentralRepositoryImpl(remote: getIt<VanCentralRemoteDataSource>()),
    )
    ..registerFactory<FindDriverOccupancy>(
      () => FindDriverOccupancy(getIt<VanCentralRepository>()),
    )
    ..registerFactory<FindDriverAttendance>(
      () => FindDriverAttendance(getIt<VanCentralRepository>()),
    )
    ..registerFactory<ChangeAcceptingStudents>(
      () => ChangeAcceptingStudents(getIt<VanCentralRepository>()),
    )
    ..registerFactory<ListVanAssistants>(
      () => ListVanAssistants(getIt<VanCentralRepository>()),
    )
    ..registerFactory<VanCentralCubit>(
      () => VanCentralCubit(
        listMyVans: getIt<ListMyVans>(),
        findMyServiceAreas: getIt<FindMyServiceAreas>(),
        findDriverOccupancy: getIt<FindDriverOccupancy>(),
        findDriverAttendance: getIt<FindDriverAttendance>(),
        changeAcceptingStudents: getIt<ChangeAcceptingStudents>(),
        listVanAssistants: getIt<ListVanAssistants>(),
      ),
    );
}
