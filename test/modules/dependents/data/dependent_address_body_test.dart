import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/dependent_request_body.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_address_draft.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../dependents_fixtures.dart';

const pickedPlace = DependentAddressDraft(
  placeId: 'place-qnl5',
  sessionToken: 'session-1',
  label: 'QNL 5 Conjunto A',
  number: '12',
  complement: 'Casa',
);

void main() {
  test('a picked place is sent as placeId and sessionToken', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        const DependentDraft(name: 'Helena', address: pickedPlace),
      ),
    );

    final address = body['address']! as Map<String, Object?>;
    expect(address['placeId'], 'place-qnl5');
    expect(address['sessionToken'], 'session-1');
    expect(address['number'], '12');
    expect(address['complement'], 'Casa');
  });

  test('no address component is ever sent', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        const DependentDraft(name: 'Helena', address: pickedPlace),
      ),
    );

    final address = body['address']! as Map<String, Object?>;
    for (final forbidden in const [
      'city',
      'cityToken',
      'cityName',
      'state',
      'stateUf',
      'district',
      'zipCode',
      'street',
    ]) {
      expect(address.containsKey(forbidden), isFalse, reason: forbidden);
    }
  });

  test('creating without an address carries no address key', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(const DependentDraft(name: 'Helena')),
    );

    expect(body.containsKey('address'), isFalse);
  });

  test('an untouched address is absent from an update', () {
    const dependent = TestDependent(
      token: 'dep-1',
      name: 'Helena Souza',
      address: TestDependentAddress(),
    );

    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(dependent).withName('Lena'),
        snapshot: dependent,
      ),
    );

    expect(body.containsKey('address'), isFalse);
  });

  test('replacing the place sends the new placeId', () {
    const dependent = TestDependent(
      token: 'dep-1',
      name: 'Helena Souza',
      address: TestDependentAddress(),
    );

    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(dependent).withAddress(pickedPlace),
        snapshot: dependent,
      ),
    );

    final address = body['address']! as Map<String, Object?>;
    expect(address['placeId'], 'place-qnl5');
  });

  test('removing the address sends an explicit null', () {
    const dependent = TestDependent(
      token: 'dep-1',
      name: 'Helena Souza',
      address: TestDependentAddress(),
    );

    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(dependent).withAddress(null),
        snapshot: dependent,
      ),
    );

    expect(body.containsKey('address'), isTrue);
    expect(body['address'], isNull);
  });

  test('amending only the number keeps the address without a placeId', () {
    const dependent = TestDependent(
      token: 'dep-1',
      name: 'Helena Souza',
      address: TestDependentAddress(number: '12'),
    );

    final draft = DependentDraft.fromDependent(dependent);
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: draft.withAddress(draft.address!.withNumber('340')),
        snapshot: dependent,
      ),
    );

    final address = body['address']! as Map<String, Object?>;
    expect(address['number'], '340');
    expect(address.containsKey('placeId'), isFalse);
  });
}
