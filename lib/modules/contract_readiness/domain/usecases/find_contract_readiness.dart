import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/repositories/contract_readiness_repository.dart';

class FindContractReadiness {
  const FindContractReadiness(this.repository);

  final ContractReadinessRepository repository;

  Future<Result<ContractReadinessFailure, ContractReadiness>> call(
    List<String> dependentTokens,
  ) {
    return repository.findReadiness(dependentTokens);
  }
}
