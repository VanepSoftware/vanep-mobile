import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/data/datasources/client_vans_remote_datasource.dart';
import 'package:vanep_mobile/modules/client_vans/data/repositories/client_vans_repository_impl.dart';
import 'package:vanep_mobile/modules/client_vans/domain/repositories/client_vans_repository.dart';
import 'package:vanep_mobile/modules/client_vans/domain/usecases/find_my_client_vans.dart';
import 'package:vanep_mobile/modules/client_vans/presentation/cubit/client_vans_cubit.dart';

void registerClientVansDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<ClientVansDataSource>(
      ClientVansRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<ClientVansRepository>(
      ClientVansRepositoryImpl(dataSource: getIt<ClientVansDataSource>()),
    )
    ..registerFactory<FindMyClientVans>(
      () => FindMyClientVans(getIt<ClientVansRepository>()),
    )
    ..registerFactory<ClientVansCubit>(
      () => ClientVansCubit(findMyClientVans: getIt<FindMyClientVans>()),
    );
}
