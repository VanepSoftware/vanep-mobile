import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/usecases/find_contract_readiness.dart';

import '../contract_readiness_mocks.dart';

void main() {
  test('FindContractReadiness forwards the result of the repository', () async {
    final repository = MockContractReadinessRepository();
    when(() => repository.findReadiness(any())).thenAnswer(
      (_) async => const Err<ContractReadinessFailure, ContractReadiness>(
        ContractReadinessFailure.network,
      ),
    );

    final result = await FindContractReadiness(repository)([
      'dep-pedro',
      'dep-ana',
    ]);

    expect(result.errorOrNull, ContractReadinessFailure.network);
    verify(() => repository.findReadiness(['dep-pedro', 'dep-ana'])).called(1);
  });
}
