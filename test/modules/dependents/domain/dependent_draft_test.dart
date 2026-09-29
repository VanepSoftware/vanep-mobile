import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../dependents_fixtures.dart';

const helenaWithAddress = TestDependent(
  token: 'dep-helena',
  name: 'Helena Souza',
  address: TestDependentAddress(complement: 'Casa 2'),
);

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

  group('address', () {
    test('a dependent without an address starts with a blank draft', () {
      final draft = DependentDraft.fromDependent(testHelenaDependent);

      expect(draft.address.isBlank, isTrue);
    });

    test('fromDependent hydrates the postal draft from the address', () {
      final address = DependentDraft.fromDependent(helenaWithAddress).address;

      expect(address.zipCode, '72120120');
      expect(address.cityToken, 'city-brasilia');
      expect(address.cityName, 'Brasília');
      expect(address.uf, 'DF');
      expect(address.street, 'QNL 5 Conjunto A');
      expect(address.number, '12');
      expect(address.complement, 'Casa 2');
      expect(address.neighborhood, 'Taguatinga');
      expect(address.isCityLocked, isTrue);
      expect(address.isNeighborhoodLocked, isTrue);
    });

    test('an address without neighborhood leaves the field open', () {
      final address = DependentDraft.fromDependent(
        const TestDependent(
          token: 'dep-1',
          name: 'Helena',
          address: TestDependentAddress(neighborhood: null),
        ),
      ).address;

      expect(address.isNeighborhoodLocked, isFalse);
    });

    test('an untouched address is not edited', () {
      expect(
        isDependentAddressEdited(
          DependentDraft.fromDependent(helenaWithAddress),
          helenaWithAddress,
        ),
        isFalse,
      );
    });

    test('changing only the number is an edit', () {
      final draft = DependentDraft.fromDependent(helenaWithAddress);

      expect(
        isDependentAddressEdited(
          draft.withAddress(draft.address.withNumber('340')),
          helenaWithAddress,
        ),
        isTrue,
      );
    });

    test('a blank draft against no address is not an edit', () {
      expect(
        isDependentAddressEdited(const DependentDraft(), testHelenaDependent),
        isFalse,
      );
    });

    test('withAddress replaces only the address', () {
      const draft = DependentDraft(name: 'Helena', gender: Gender.female);

      final updated = draft.withAddress(fakeCompleteDraft());

      expect(updated.address.cityToken, 'city-brasilia');
      expect(updated.name, 'Helena');
      expect(updated.gender, Gender.female);
    });
  });

  group('findAddressIssues', () {
    test('a blank address has no pending issue', () {
      expect(findAddressIssues(const DependentDraft(name: 'Helena')), isEmpty);
    });

    test('a partial address lists what is missing', () {
      final draft = const DependentDraft(
        name: 'Helena',
      ).withAddress(const PostalAddressDraft().withStreet('Rua Sete'));

      expect(findAddressIssues(draft), {
        PostalAddressIssue.cityRequired,
        PostalAddressIssue.zipCodeInvalid,
      });
    });

    test('a complete address has no pending issue', () {
      final draft = const DependentDraft(
        name: 'Helena',
      ).withAddress(fakeCompleteDraft());

      expect(findAddressIssues(draft), isEmpty);
    });

    test('a saved address the person did not touch is never blocked', () {
      const legacy = TestDependent(
        token: 'dep-legacy',
        name: 'Helena',
        address: TestDependentAddress(zipCode: null),
      );

      expect(
        findAddressIssues(
          DependentDraft.fromDependent(legacy).withName('Helena Maria'),
          snapshot: legacy,
        ),
        isEmpty,
      );
    });

    test('editing a saved address that is now incomplete is blocked', () {
      const legacy = TestDependent(
        token: 'dep-legacy',
        name: 'Helena',
        address: TestDependentAddress(zipCode: null),
      );
      final draft = DependentDraft.fromDependent(legacy);

      expect(
        findAddressIssues(
          draft.withAddress(draft.address.withNumber('340')),
          snapshot: legacy,
        ),
        {PostalAddressIssue.zipCodeInvalid},
      );
    });
  });
}
