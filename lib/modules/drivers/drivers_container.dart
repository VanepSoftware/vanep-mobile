import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/drivers/data/datasources/driver_remote_datasource.dart';
import 'package:vanep_mobile/modules/drivers/data/repositories/driver_repository_impl.dart';
import 'package:vanep_mobile/modules/drivers/domain/repositories/driver_repository.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/find_driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/usecases/list_recent_drivers.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/driver_profile_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';

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
