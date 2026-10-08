import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/driver_service_areas/data/datasources/driver_service_area_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_service_areas/data/repositories/driver_service_area_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/repositories/driver_service_area_repository.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/find_my_service_areas.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/usecases/replace_my_service_areas.dart';
import 'package:vanep_mobile/modules/driver_service_areas/presentation/cubit/driver_service_areas_cubit.dart';

void registerDriverServiceAreasDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<DriverServiceAreaRemoteDataSource>(
      DriverServiceAreaRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<DriverServiceAreaRepository>(
      DriverServiceAreaRepositoryImpl(
        remote: getIt<DriverServiceAreaRemoteDataSource>(),
      ),
    )
    ..registerFactory<FindMyServiceAreas>(
      () => FindMyServiceAreas(getIt<DriverServiceAreaRepository>()),
    )
    ..registerFactory<ReplaceMyServiceAreas>(
      () => ReplaceMyServiceAreas(getIt<DriverServiceAreaRepository>()),
    )
    ..registerFactory<DriverServiceAreasCubit>(
      () => DriverServiceAreasCubit(
        findMyServiceAreas: getIt<FindMyServiceAreas>(),
        replaceMyServiceAreas: getIt<ReplaceMyServiceAreas>(),
      ),
    );
}
