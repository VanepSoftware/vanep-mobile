import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/dtos/contract_readiness_dto.dart';

class ContractReadinessRemoteDataSource {
  ContractReadinessRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  Future<ContractReadiness> findReadiness(List<String> dependentTokens) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.contractReadinessEndpoint,
      queryParameters: {
        'dependentTokens': ListParam(dependentTokens, ListFormat.multi),
      },
    );
    final payload = response.data;
    if (payload == null) {
      throw const FormatException('Empty contract readiness payload.');
    }
    return contractReadinessFromJson(Map<String, Object?>.from(payload));
  }
}
