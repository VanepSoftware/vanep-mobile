import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';

void main() {
  test('creating with every field touches every field', () {
    final changes = buildDependentChangesForCreate(
      const DependentDraft(
        name: 'Helena',
        birthDate: '2015-03-22',
        gender: Gender.female,
      ),
    );

    expect(changes.touchedFields, {
      DependentField.name,
      DependentField.birthDate,
      DependentField.gender,
    });
  });

  test('creating with the name alone touches only the name', () {
    final changes = buildDependentChangesForCreate(
      const DependentDraft(name: 'Helena'),
    );

    expect(changes.touchedFields, {DependentField.name});
  });

  test('creating with a blank birth date does not touch it', () {
    final changes = buildDependentChangesForCreate(
      const DependentDraft(name: 'Helena', birthDate: '   '),
    );

    expect(changes.touches(DependentField.birthDate), isFalse);
  });

  test('updating only the name touches only the name', () {
    final changes = buildDependentChangesForUpdate(
      draft: DependentDraft.fromDependent(
        testHelenaDependent,
      ).withName('Helena Maria Souza'),
      snapshot: testHelenaDependent,
    );

    expect(changes.touchedFields, {DependentField.name});
    expect(changes.draft.name, 'Helena Maria Souza');
  });

  test('clearing the gender touches it and carries a null value', () {
    final changes = buildDependentChangesForUpdate(
      draft: DependentDraft.fromDependent(
        testHelenaDependent,
      ).withGender(null),
      snapshot: testHelenaDependent,
    );

    expect(changes.touchedFields, {DependentField.gender});
    expect(changes.draft.gender, isNull);
  });

  test('clearing the birth date touches it', () {
    final changes = buildDependentChangesForUpdate(
      draft: DependentDraft.fromDependent(
        testHelenaDependent,
      ).withBirthDate(null),
      snapshot: testHelenaDependent,
    );

    expect(changes.touchedFields, {DependentField.birthDate});
    expect(changes.draft.birthDate, isNull);
  });

  test('an untouched draft produces no changes', () {
    final changes = buildDependentChangesForUpdate(
      draft: DependentDraft.fromDependent(testHelenaDependent),
      snapshot: testHelenaDependent,
    );

    expect(changes.isEmpty, isTrue);
  });

  test('whitespace around an unchanged value is not a change', () {
    final changes = buildDependentChangesForUpdate(
      draft: DependentDraft.fromDependent(
        testHelenaDependent,
      ).withName('  Helena Souza  '),
      snapshot: testHelenaDependent,
    );

    expect(changes.isEmpty, isTrue);
  });

  test('filling a field that was empty touches it', () {
    final changes = buildDependentChangesForUpdate(
      draft: DependentDraft.fromDependent(
        testDependentWithoutBirthDate,
      ).withBirthDate('2020-01-10'),
      snapshot: testDependentWithoutBirthDate,
    );

    expect(changes.touchedFields, {DependentField.birthDate});
  });
}
