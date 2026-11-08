import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/dependents/domain/failures/dependent_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

void main() {
  test('a validation failure without a field is not attributed', () {
    const failure = DependentValidationFailure();

    expect(failure.isAttributedToAField, isFalse);
  });

  test('a validation failure attributed to a field exposes it', () {
    const failure = DependentValidationFailure(
      messagesByField: {DependentField.name: 'Nome muito longo.'},
    );

    expect(failure.isAttributedToAField, isTrue);
    expect(failure.messagesByField[DependentField.name], 'Nome muito longo.');
  });

  test('rejections are equal only with the same detail', () {
    expect(
      const DependentRejectedFailure(detail: 'a'),
      equals(const DependentRejectedFailure(detail: 'a')),
    );
    expect(
      const DependentRejectedFailure(detail: 'a'),
      isNot(equals(const DependentRejectedFailure(detail: 'b'))),
    );
  });

  test('failures of the same kind are equal', () {
    expect(
      const DependentNetworkFailure(),
      equals(const DependentNetworkFailure()),
    );
    expect(
      const DependentValidationFailure(
        messagesByField: {DependentField.name: 'a'},
      ),
      isNot(
        equals(
          const DependentValidationFailure(
            messagesByField: {DependentField.name: 'b'},
          ),
        ),
      ),
    );
  });
}
