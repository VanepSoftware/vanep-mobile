import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/driver_search/data/datasources/driver_search_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_search/data/repositories/driver_search_repository_impl.dart';
import 'package:vanep_mobile/modules/driver_search/domain/repositories/driver_search_repository.dart';
import 'package:vanep_mobile/modules/driver_search/domain/usecases/search_drivers_by_place.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';

void registerDriverSearchDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<DriverSearchRemoteDataSource>(
      DriverSearchRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<DriverSearchRepository>(
      DriverSearchRepositoryImpl(
        remote: getIt<DriverSearchRemoteDataSource>(),
      ),
    )
    ..registerFactory<SearchDriversByPlace>(
      () => SearchDriversByPlace(getIt<DriverSearchRepository>()),
    )
    ..registerFactory<DriverSearchCubit>(
      () => DriverSearchCubit(
        searchDriversByPlace: getIt<SearchDriversByPlace>(),
      ),
    );
}
