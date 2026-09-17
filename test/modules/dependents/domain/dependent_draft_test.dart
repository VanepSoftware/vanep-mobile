import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';

void main() {
  final today = DateTime(2026, 9, 14);

  test('DependentDraft.fromDependent copies the editable fields', () {
    final draft = DependentDraft.fromDependent(testHelenaDependent);

    expect(draft.name, 'Helena Souza');
    expect(draft.birthDate, '2015-03-22');
    expect(draft.gender, Gender.female);
  });

  test('a blank name is rejected', () {
    final errors = validateDependentDraft(
      const DependentDraft(name: '   '),
      today: today,
    );

    expect(errors[DependentField.name], DependentDraftError.nameRequired);
  });

  test('a name alone is valid', () {
    final errors = validateDependentDraft(
      const DependentDraft(name: 'Helena'),
      today: today,
    );

    expect(errors, isEmpty);
  });

  test('a birth date after today is rejected', () {
    final errors = validateDependentDraft(
      const DependentDraft(name: 'Helena', birthDate: '2026-09-15'),
      today: today,
    );

    expect(
      errors[DependentField.birthDate],
      DependentDraftError.birthDateInFuture,
    );
  });

  test('today is an acceptable birth date', () {
    final errors = validateDependentDraft(
      const DependentDraft(name: 'Helena', birthDate: '2026-09-14'),
      today: today,
    );

    expect(errors, isEmpty);
  });

  test('an unparseable birth date is rejected', () {
    final errors = validateDependentDraft(
      const DependentDraft(name: 'Helena', birthDate: 'nao-e-data'),
      today: today,
    );

    expect(
      errors[DependentField.birthDate],
      DependentDraftError.birthDateInvalid,
    );
  });

  test('an empty birth date is not an error', () {
    final errors = validateDependentDraft(
      const DependentDraft(name: 'Helena', birthDate: ''),
      today: today,
    );

    expect(errors, isEmpty);
  });

  test('withGender replaces only the gender', () {
    const draft = DependentDraft(name: 'Helena', birthDate: '2015-03-22');

    final updated = draft.withGender(Gender.female);

    expect(updated.gender, Gender.female);
    expect(updated.name, 'Helena');
    expect(updated.birthDate, '2015-03-22');
  });
}
