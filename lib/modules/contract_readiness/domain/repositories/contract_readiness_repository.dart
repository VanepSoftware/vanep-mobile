import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';

abstract class ContractReadinessRepository {
  Future<Result<ContractReadinessFailure, ContractReadiness>> findReadiness(
    List<String> dependentTokens,
  );
}
