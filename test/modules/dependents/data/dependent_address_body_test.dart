import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/dependent_request_body.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_changes.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/dependent_draft.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../dependents_fixtures.dart';

const helenaWithAddress = TestDependent(
  token: 'dep-1',
  name: 'Helena Souza',
  address: TestDependentAddress(complement: 'Casa 2'),
);

Map<String, Object?> addressBodyOf(Map<String, Object?> body) {
  return body['address']! as Map<String, Object?>;
}

void main() {
  test('a filled address is sent as the full postal object', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        DependentDraft(
          name: 'Helena',
          address: fakeCompleteDraft(
            zipCode: '72120120',
            street: 'QND 12',
            number: '10',
            complement: 'Casa',
            neighborhood: 'Taguatinga',
          ),
        ),
      ),
    );

    expect(addressBodyOf(body), {
      'cityToken': 'city-brasilia',
      'street': 'QND 12',
      'zipCode': '72120120',
      'number': '10',
      'complement': 'Casa',
      'neighborhood': 'Taguatinga',
    });
  });

  test('the optionals are always present, as null when blank', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        DependentDraft(name: 'Helena', address: fakeCompleteDraft()),
      ),
    );

    final address = addressBodyOf(body);
    for (final optional in const ['number', 'complement', 'neighborhood']) {
      expect(address.containsKey(optional), isTrue, reason: optional);
      expect(address[optional], isNull, reason: optional);
    }
  });

  test('the zip code goes out as digits only', () {
    final draft = fakeCompleteDraft().withZipCode('72120-120');

    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        DependentDraft(name: 'Helena', address: draft),
      ),
    );

    expect(addressBodyOf(body)['zipCode'], '72120120');
  });

  test('no Places or catalog-name key is ever sent', () {
    final body = dependentChangesToJson(
      buildDependentChangesForCreate(
        DependentDraft(name: 'Helena', address: fakeResolvedDraft()),
      ),
    );

    final address = addressBodyOf(body);
    for (final forbidden in const [
      'placeId',
      'sessionToken',
      'stateToken',
      'cityName',
      'uf',
      'stateUf',
      'district',
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
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(helenaWithAddress).withName('Lena'),
        snapshot: helenaWithAddress,
      ),
    );

    expect(body.containsKey('address'), isFalse);
  });

  test('changing only the number resends the whole address', () {
    final draft = DependentDraft.fromDependent(helenaWithAddress);

    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: draft.withAddress(draft.address.withNumber('340')),
        snapshot: helenaWithAddress,
      ),
    );

    expect(addressBodyOf(body), {
      'cityToken': 'city-brasilia',
      'street': 'QNL 5 Conjunto A',
      'zipCode': '72120120',
      'number': '340',
      'complement': 'Casa 2',
      'neighborhood': 'Taguatinga',
    });
  });

  test('choosing another city sends its token', () {
    final draft = DependentDraft.fromDependent(helenaWithAddress);

    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: draft.withAddress(
          draft.address
              .withUf('GO')
              .withCity(token: 'city-goiania', name: 'Goiânia', uf: 'GO'),
        ),
        snapshot: helenaWithAddress,
      ),
    );

    expect(addressBodyOf(body)['cityToken'], 'city-goiania');
  });

  test('removing the address sends an explicit null', () {
    final body = dependentChangesToJson(
      buildDependentChangesForUpdate(
        draft: DependentDraft.fromDependent(
          helenaWithAddress,
        ).withAddress(const PostalAddressDraft()),
        snapshot: helenaWithAddress,
      ),
    );

    expect(body.containsKey('address'), isTrue);
    expect(body['address'], isNull);
  });
}
