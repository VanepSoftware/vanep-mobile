import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

void main() {
  test('a validation failure without a field carries only the detail', () {
    const failure = DependentValidationFailure(detail: 'Nome muito longo.');

    expect(failure.isAttributedToAField, isFalse);
    expect(failure.detail, 'Nome muito longo.');
  });

  test('a validation failure attributed to a field exposes it', () {
    const failure = DependentValidationFailure(
      messagesByField: {DependentField.name: 'Nome muito longo.'},
    );

    expect(failure.isAttributedToAField, isTrue);
    expect(failure.messagesByField[DependentField.name], 'Nome muito longo.');
  });

  test('failures of the same kind are equal', () {
    expect(
      const DependentNetworkFailure(),
      equals(const DependentNetworkFailure()),
    );
    expect(
      const DependentValidationFailure(detail: 'a'),
      isNot(equals(const DependentValidationFailure(detail: 'b'))),
    );
  });
}
