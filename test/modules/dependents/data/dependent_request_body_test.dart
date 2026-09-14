import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/dependent_request_body.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';

void main() {
  test('a create with the name alone carries only the name', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(const DependentDraft(name: ' Helena ')),
    );

    expect(body, {'name': 'Helena'});
  });

  test('a create with every field carries every field', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        const DependentDraft(
          name: 'Helena',
          birthDate: '2015-03-22',
          gender: Gender.female,
        ),
      ),
    );

    expect(body, {
      'name': 'Helena',
      'birthDate': '2015-03-22',
      'gender': 'FEMALE',
    });
  });

  test('an untouched field is absent from the body', () {
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(testHelenaDependent).withName('Lena'),
        snapshot: testHelenaDependent,
      ),
    );

    expect(body.keys, ['name']);
    expect(body.containsKey('gender'), isFalse);
    expect(body.containsKey('birthDate'), isFalse);
  });

  test('a cleared field is sent as an explicit null', () {
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(testHelenaDependent).withGender(null),
        snapshot: testHelenaDependent,
      ),
    );

    expect(body.containsKey('gender'), isTrue);
    expect(body['gender'], isNull);
  });

  test('a cleared birth date is sent as an explicit null', () {
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(
          testHelenaDependent,
        ).withBirthDate(''),
        snapshot: testHelenaDependent,
      ),
    );

    expect(body.containsKey('birthDate'), isTrue);
    expect(body['birthDate'], isNull);
  });

  test('an unchanged draft produces an empty body', () {
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(testHelenaDependent),
        snapshot: testHelenaDependent,
      ),
    );

    expect(body, isEmpty);
  });
}
