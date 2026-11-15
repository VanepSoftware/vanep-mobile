import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/contract_readiness/data/dtos/contract_readiness_dto.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';

import '../contract_readiness_mocks.dart';

void main() {
  test('reads the gaps with and without a dependent token', () {
    expect(
      contractReadinessFromJson(readinessJson),
      const ContractReadiness(
        ready: false,
        gaps: [
          ReadinessGap(
            subject: ContractReadinessSubject.client,
            field: ContractReadinessField.phone,
          ),
          ReadinessGap(
            subject: ContractReadinessSubject.dependent,
            dependentToken: 'dep-pedro',
            field: ContractReadinessField.school,
          ),
        ],
      ),
    );
  });

  test('a ready answer has no gaps', () {
    expect(
      contractReadinessFromJson(const {'ready': true, 'missing': []}),
      const ContractReadiness(ready: true, gaps: []),
    );
  });

  test('a gap with an unknown subject or field is left out', () {
    final readiness = contractReadinessFromJson(const {
      'ready': false,
      'missing': [
        {'subject': 'VAN', 'field': 'PHONE'},
        {'subject': 'DEPENDENT', 'dependentToken': 'dep-ana', 'field': 'PET'},
        {
          'subject': 'DEPENDENT',
          'dependentToken': 'dep-ana',
          'field': 'BIRTH_DATE',
        },
      ],
    });

    expect(readiness.gaps, const [
      ReadinessGap(
        subject: ContractReadinessSubject.dependent,
        dependentToken: 'dep-ana',
        field: ContractReadinessField.birthDate,
      ),
    ]);
  });
}
