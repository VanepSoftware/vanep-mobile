import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';

const pedroToken = 'dep-pedro';
const anaToken = 'dep-ana';

const readinessWithGaps = ContractReadiness(
  ready: false,
  gaps: [
    ReadinessGap(
      subject: ContractReadinessSubject.client,
      field: ContractReadinessField.phone,
    ),
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      dependentToken: pedroToken,
      field: ContractReadinessField.school,
    ),
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      dependentToken: pedroToken,
      field: ContractReadinessField.schoolDays,
    ),
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      dependentToken: anaToken,
      field: ContractReadinessField.birthDate,
    ),
  ],
);

void main() {
  group('ContractReadinessSubject.fromApi', () {
    test('maps the API values', () {
      expect(
        ContractReadinessSubject.fromApi('CLIENT'),
        ContractReadinessSubject.client,
      );
      expect(
        ContractReadinessSubject.fromApi('DEPENDENT'),
        ContractReadinessSubject.dependent,
      );
      expect(ContractReadinessSubject.fromApi('DRIVER'), isNull);
      expect(ContractReadinessSubject.fromApi(null), isNull);
    });
  });

  group('ContractReadinessField.fromApi', () {
    test('maps every API value', () {
      expect(
        ContractReadinessField.fromApi('DOCUMENT'),
        ContractReadinessField.document,
      );
      expect(
        ContractReadinessField.fromApi('PHONE'),
        ContractReadinessField.phone,
      );
      expect(
        ContractReadinessField.fromApi('ADDRESS'),
        ContractReadinessField.address,
      );
      expect(
        ContractReadinessField.fromApi('BIRTH_DATE'),
        ContractReadinessField.birthDate,
      );
      expect(
        ContractReadinessField.fromApi('SCHOOL'),
        ContractReadinessField.school,
      );
      expect(
        ContractReadinessField.fromApi('SCHOOL_DAYS'),
        ContractReadinessField.schoolDays,
      );
    });

    test('an unknown value is null', () {
      expect(ContractReadinessField.fromApi('EMAIL'), isNull);
      expect(ContractReadinessField.fromApi(7), isNull);
    });
  });

  group('gapsOfDependent', () {
    test('keeps only the dependent entries of that token', () {
      expect(readinessWithGaps.gapsOfDependent(pedroToken), {
        ContractReadinessField.school,
        ContractReadinessField.schoolDays,
      });
    });

    test('ignores client entries', () {
      expect(readinessWithGaps.gapsOfDependent(anaToken), {
        ContractReadinessField.birthDate,
      });
    });

    test('a dependent with no entry has no gaps', () {
      expect(readinessWithGaps.gapsOfDependent('dep-davi'), isEmpty);
    });
  });

  test('two readiness values with the same gaps are equal', () {
    const first = ContractReadiness(ready: true, gaps: []);
    const second = ContractReadiness(ready: true, gaps: []);

    expect(first, second);
  });
}
