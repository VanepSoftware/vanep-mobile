import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/datasources/ibge_locations_remote_datasource.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/repositories/ibge_locations_repository_impl.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/repositories/ibge_locations_repository.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_cities.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/list_states.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/usecases/lookup_cep.dart';

void registerIbgeLocationsDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<IbgeLocationsRemoteDataSource>(
      IbgeLocationsRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<IbgeLocationsRepository>(
      IbgeLocationsRepositoryImpl(
        remote: getIt<IbgeLocationsRemoteDataSource>(),
      ),
    )
    ..registerFactory<LookupCep>(
      () => LookupCep(getIt<IbgeLocationsRepository>()),
    )
    ..registerFactory<ListStates>(
      () => ListStates(getIt<IbgeLocationsRepository>()),
    )
    ..registerFactory<ListCities>(
      () => ListCities(getIt<IbgeLocationsRepository>()),
    );
}
