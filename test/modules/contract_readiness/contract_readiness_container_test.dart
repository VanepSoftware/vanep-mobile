import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/modules/contract_readiness/contract_readiness_container.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/repositories/contract_readiness_repository.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';

import 'contract_readiness_mocks.dart';

void main() {
  test('registers the repository and FindContractReadiness', () {
    final getIt = GetIt.asNewInstance()
      ..registerSingleton<Environment>(testReadinessEnvironment)
      ..registerSingleton<Dio>(Dio(), instanceName: authenticatedDioName);

    registerContractReadinessDependencies(getIt);

    expect(
      getIt<ContractReadinessRepository>(),
      isA<ContractReadinessRepository>(),
    );
    expect(getIt<FindContractReadiness>(), isA<FindContractReadiness>());
  });
}
