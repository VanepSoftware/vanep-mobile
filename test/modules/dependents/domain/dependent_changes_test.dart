import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../dependents_fixtures.dart';

const helenaWithAddress = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  address: TestDependentAddress(complement: 'Casa 2'),
);

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
      draft: DependentDraft.fromDependent(testHelenaDependent).withGender(null),
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

  group('address', () {
    test('creating with a filled address touches it', () {
      final changes = buildDependentChangesForCreate(
        const DependentDraft(name: 'Helena').withAddress(fakeCompleteDraft()),
      );

      expect(changes.touchedFields, {
        DependentField.name,
        DependentField.address,
      });
    });

    test('creating with a blank address does not touch it', () {
      final changes = buildDependentChangesForCreate(
        const DependentDraft(name: 'Helena'),
      );

      expect(changes.touches(DependentField.address), isFalse);
    });

    test('an untouched address produces no change', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(helenaWithAddress),
        snapshot: helenaWithAddress,
      );

      expect(changes.isEmpty, isTrue);
    });

    test('changing only the number touches the whole address', () {
      final draft = DependentDraft.fromDependent(helenaWithAddress);

      final changes = buildDependentChangesForUpdate(
        draft: draft.withAddress(draft.address.withNumber('340')),
        snapshot: helenaWithAddress,
      );

      expect(changes.touchedFields, {DependentField.address});
    });

    test('choosing another city touches the address', () {
      final draft = DependentDraft.fromDependent(helenaWithAddress);

      final changes = buildDependentChangesForUpdate(
        draft: draft.withAddress(
          draft.address
              .withUf('GO')
              .withCity(token: 'city-goiania', name: 'Goiânia', uf: 'GO'),
        ),
        snapshot: helenaWithAddress,
      );

      expect(changes.touches(DependentField.address), isTrue);
    });

    test('blanking a saved address touches it', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(
          helenaWithAddress,
        ).withAddress(const PostalAddressDraft()),
        snapshot: helenaWithAddress,
      );

      expect(changes.touchedFields, {DependentField.address});
    });

    test('adding an address to a dependent without one touches it', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(
          testHelenaDependent,
        ).withAddress(fakeCompleteDraft()),
        snapshot: testHelenaDependent,
      );

      expect(changes.touchedFields, {DependentField.address});
    });
  });

  group('document and school', () {
    const pedro = TestDependent(
      token: 'dep-pedro',
      name: 'Pedro Oliveira',
      document: '52998224725',
      school: TestDependentSchool(),
    );

    test('creating with a CPF and a school touches both', () {
      final changes = buildDependentChangesForCreate(
        const DependentDraft(
          name: 'Pedro',
          document: '529.982.247-25',
          schoolToken: 'school-delta',
        ),
      );

      expect(changes.touchedFields, {
        DependentField.name,
        DependentField.document,
        DependentField.school,
      });
    });

    test('creating with a blank CPF does not touch it', () {
      final changes = buildDependentChangesForCreate(
        const DependentDraft(name: 'Pedro', document: '  '),
      );

      expect(changes.touches(DependentField.document), isFalse);
    });

    test('the same CPF with a mask is not a change', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(pedro).withDocument('529.982.247-25'),
        snapshot: pedro,
      );

      expect(changes.isEmpty, isTrue);
    });

    test('another CPF touches the document', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(pedro).withDocument('390.533.447-05'),
        snapshot: pedro,
      );

      expect(changes.touchedFields, {DependentField.document});
    });

    test('clearing the CPF touches the document', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(pedro).withDocument(''),
        snapshot: pedro,
      );

      expect(changes.touchedFields, {DependentField.document});
    });

    test('another school touches the school', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(
          pedro,
        ).withSchoolToken('school-horizonte'),
        snapshot: pedro,
      );

      expect(changes.touchedFields, {DependentField.school});
    });

    test('the same school is not a change', () {
      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(
          pedro,
        ).withSchoolToken('school-delta'),
        snapshot: pedro,
      );

      expect(changes.isEmpty, isTrue);
    });

    test('a school without a token is not a change when untouched', () {
      const withBlankSchool = TestDependent(
        token: 'dep-pedro',
        name: 'Pedro Oliveira',
        school: TestDependentSchool(token: ''),
      );

      final changes = buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(withBlankSchool),
        snapshot: withBlankSchool,
      );

      expect(changes.isEmpty, isTrue);
    });
  });
}
