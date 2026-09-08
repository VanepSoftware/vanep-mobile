import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/driver_service_area_remote_datasource.dart';
import 'data/repositories/driver_service_area_repository_impl.dart';
import 'domain/repositories/driver_service_area_repository.dart';
import 'domain/usecases/find_my_service_areas.dart';
import 'domain/usecases/replace_my_service_areas.dart';
import 'presentation/cubit/driver_service_areas_cubit.dart';

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
