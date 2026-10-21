import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/repositories/contract_readiness_repository_impl.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';

import '../contract_readiness_mocks.dart';

void main() {
  late MockContractReadinessRemoteDataSource remote;
  late ContractReadinessRepositoryImpl repository;

  setUp(() {
    remote = MockContractReadinessRemoteDataSource();
    repository = ContractReadinessRepositoryImpl(remote: remote);
  });

  test('the readiness is returned as Ok', () async {
    const readiness = ContractReadiness(ready: true, gaps: []);
    when(() => remote.findReadiness(any())).thenAnswer((_) async => readiness);

    final result = await repository.findReadiness(['dep-pedro']);

    expect(result.valueOrNull, readiness);
    verify(() => remote.findReadiness(['dep-pedro'])).called(1);
  });

  test('no response maps to a network failure', () async {
    when(() => remote.findReadiness(any()))
        .thenThrow(readinessDioFailure(null));

    final result = await repository.findReadiness(['dep-pedro']);

    expect(result.errorOrNull, ContractReadinessFailure.network);
  });

  for (final status in [403, 404, 500]) {
    test('$status maps to unexpected', () async {
      when(() => remote.findReadiness(any()))
          .thenThrow(readinessDioFailure(status));

      final result = await repository.findReadiness(['dep-pedro']);

      expect(result.errorOrNull, ContractReadinessFailure.unexpected);
    });
  }

  test('an unreadable payload maps to unexpected', () async {
    when(() => remote.findReadiness(any()))
        .thenThrow(const FormatException('Empty contract readiness payload.'));

    final result = await repository.findReadiness(['dep-pedro']);

    expect(result.errorOrNull, ContractReadinessFailure.unexpected);
  });
}
