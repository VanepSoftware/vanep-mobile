import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/datasources/contract_readiness_remote_datasource.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/repositories/contract_readiness_repository_impl.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/repositories/contract_readiness_repository.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';

void registerContractReadinessDependencies(GetIt getIt) {
  final environment = getIt<Environment>();
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<ContractReadinessRemoteDataSource>(
      ContractReadinessRemoteDataSource(
        dio: authenticatedDio,
        environment: environment,
      ),
    )
    ..registerSingleton<ContractReadinessRepository>(
      ContractReadinessRepositoryImpl(
        remote: getIt<ContractReadinessRemoteDataSource>(),
      ),
    )
    ..registerFactory<FindContractReadiness>(
      () => FindContractReadiness(getIt<ContractReadinessRepository>()),
    );
}
