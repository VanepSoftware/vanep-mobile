import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/driver_remote_datasource.dart';
import 'data/repositories/driver_repository_impl.dart';
import 'domain/repositories/driver_repository.dart';
import 'domain/usecases/find_driver_profile.dart';
import 'domain/usecases/list_recent_drivers.dart';
import 'presentation/cubit/driver_profile_cubit.dart';
import 'presentation/cubit/drivers_cubit.dart';

void registerDriverDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<DriverRemoteDataSource>(
      DriverRemoteDataSource(dio: authenticatedDio, environment: environment),
    )
    ..registerSingleton<DriverRepository>(
      DriverRepositoryImpl(remote: getIt<DriverRemoteDataSource>()),
    )
    ..registerFactory<ListRecentDrivers>(
      () => ListRecentDrivers(getIt<DriverRepository>()),
    )
    ..registerFactory<DriversCubit>(
      () => DriversCubit(listRecentDrivers: getIt<ListRecentDrivers>()),
    )
    ..registerFactory<FindDriverProfile>(
      () => FindDriverProfile(getIt<DriverRepository>()),
    )
    ..registerFactoryParam<DriverProfileCubit, String, void>(
      (driverToken, _) => DriverProfileCubit(
        findDriverProfile: getIt<FindDriverProfile>(),
        driverToken: driverToken,
      ),
    );
}
