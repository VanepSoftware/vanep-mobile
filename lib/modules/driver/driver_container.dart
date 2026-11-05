import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/environment/environment.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/driver_home_remote_datasource.dart';
import 'data/repositories/driver_home_repository_impl.dart';
import 'domain/repositories/driver_home_repository.dart';
import 'presentation/cubit/driver_home_cubit.dart';

void registerDriverHomeDependencies(GetIt getIt) {
  if (!getIt.isRegistered<DriverHomeRepository>() &&
      getIt.isRegistered<Environment>() &&
      getIt.isRegistered<Dio>(instanceName: authenticatedDioName)) {
    getIt
      ..registerSingleton<DriverHomeRemoteDataSource>(
        DriverHomeRemoteDataSource(
          dio: getIt<Dio>(instanceName: authenticatedDioName),
          environment: getIt<Environment>(),
        ),
      )
      ..registerSingleton<DriverHomeRepository>(
        DriverHomeRepositoryImpl(remote: getIt<DriverHomeRemoteDataSource>()),
      );
  }

  getIt.registerFactory<DriverHomeCubit>(
    () => DriverHomeCubit(
      repository: getIt.isRegistered<DriverHomeRepository>()
          ? getIt<DriverHomeRepository>()
          : null,
    ),
  );
}
