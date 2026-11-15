import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/repositories/contract_readiness_repository.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/datasources/contract_readiness_remote_datasource.dart';

ContractReadinessFailure contractReadinessFailureFrom(DioException exception) {
  if (exception.response?.statusCode == null) {
    return ContractReadinessFailure.network;
  }
  return ContractReadinessFailure.unexpected;
}

class ContractReadinessRepositoryImpl implements ContractReadinessRepository {
  const ContractReadinessRepositoryImpl({required this.remote});

  final ContractReadinessRemoteDataSource remote;

  @override
  Future<Result<ContractReadinessFailure, ContractReadiness>> findReadiness(
    List<String> dependentTokens,
  ) async {
    try {
      return Ok(await remote.findReadiness(dependentTokens));
    } on DioException catch (exception) {
      return Err(contractReadinessFailureFrom(exception));
    } on FormatException {
      return const Err(ContractReadinessFailure.unexpected);
    }
  }
}
