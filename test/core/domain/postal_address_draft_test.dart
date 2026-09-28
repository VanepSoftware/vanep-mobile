import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';

import 'postal_address_draft_fixture.dart';

void main() {
  group('zip code', () {
    test('keeps digits only', () {
      expect(
        const PostalAddressDraft().withZipCode('72120-120').zipCode,
        '72120120',
      );
    });

    test('is limited to eight digits', () {
      expect(
        const PostalAddressDraft().withZipCode('721201209999').zipCode,
        '72120120',
      );
    });

    test(
      'making it incomplete unlocks a locked city so the picker is free',
      () {
        final saved = PostalAddressDraft.fromParts(
          zipCode: '72120120',
          cityToken: 'city-brasilia',
          cityName: 'Brasília',
          uf: 'DF',
          street: 'QND 12',
        );

        final editing = saved.withZipCode('7212012');

        expect(saved.isCityLocked, isTrue);
        expect(editing.isCityLocked, isFalse);
        expect(editing.cityToken, 'city-brasilia');
        expect(editing.street, 'QND 12');
      },
    );

    test('clearing it unlocks the city too', () {
      final saved = PostalAddressDraft.fromParts(
        zipCode: '72120120',
        cityToken: 'city-brasilia',
        cityName: 'Brasília',
        uf: 'DF',
      );

      expect(saved.withZipCode('').isCityLocked, isFalse);
    });

    test(
      'another complete zip keeps a locked city locked until the lookup',
      () {
        final saved = PostalAddressDraft.fromParts(
          zipCode: '72120120',
          cityToken: 'city-brasilia',
          cityName: 'Brasília',
          uf: 'DF',
        );

        expect(saved.withZipCode('70040-010').isCityLocked, isTrue);
      },
    );

    test('a zip that stays incomplete keeps the picker free', () {
      final draft = fakeCompleteDraft().unlockCity().withZipCode('7212');

      expect(draft.isCityLocked, isFalse);
    });

    test('changing it clears the unknown-CEP block', () {
      final unknown = fakeCompleteDraft().withCepUnknown();

      expect(unknown.withZipCode('70040010').isZipCodeUnknown, isFalse);
    });
  });

  group('text fields', () {
    test('keep the raw text so trailing spaces survive typing', () {
      expect(const PostalAddressDraft().withStreet('Rua ').street, 'Rua ');
    });

    test('are limited to the backend caps', () {
      final draft = const PostalAddressDraft()
          .withStreet('a' * 300)
          .withNumber('1' * 20)
          .withComplement('c' * 200)
          .withNeighborhood('b' * 200);

      expect(draft.street.length, PostalAddressLimits.street);
      expect(draft.number.length, PostalAddressLimits.number);
      expect(draft.complement.length, PostalAddressLimits.complement);
      expect(draft.neighborhood.length, PostalAddressLimits.neighborhood);
      expect(PostalAddressLimits.street, 255);
      expect(PostalAddressLimits.number, 16);
      expect(PostalAddressLimits.complement, 128);
      expect(PostalAddressLimits.neighborhood, 128);
    });
  });

  group('blank, complete and savable', () {
    test('an empty draft is blank, incomplete and lists every issue', () {
      const draft = PostalAddressDraft();

      expect(draft.isBlank, isTrue);
      expect(draft.isComplete, isFalse);
      expect(draft.issues, {
        PostalAddressIssue.cityRequired,
        PostalAddressIssue.streetRequired,
        PostalAddressIssue.zipCodeInvalid,
      });
    });

    test('city token, street and eight zip digits make it complete', () {
      final draft = fakeCompleteDraft();

      expect(draft.isBlank, isFalse);
      expect(draft.isComplete, isTrue);
      expect(draft.issues, isEmpty);
    });

    test('number, complement and neighborhood alone do not complete it', () {
      final draft = const PostalAddressDraft()
          .withNumber('10')
          .withComplement('Casa 2')
          .withNeighborhood('Taguatinga');

      expect(draft.isBlank, isFalse);
      expect(draft.isComplete, isFalse);
    });

    test('a blank street does not count', () {
      expect(fakeCompleteDraft(street: '   ').issues, {
        PostalAddressIssue.streetRequired,
      });
    });

    test('a short zip is reported as invalid', () {
      expect(fakeCompleteDraft(zipCode: '7212012').issues, {
        PostalAddressIssue.zipCodeInvalid,
      });
    });

    test('a complete draft is savable', () {
      expect(fakeCompleteDraft().isSavable, isTrue);
    });

    test('a complete draft with an unknown CEP is not savable', () {
      final draft = fakeCompleteDraft().copyWith(isZipCodeUnknown: true);

      expect(draft.isComplete, isTrue);
      expect(draft.isSavable, isFalse);
    });
  });

  group('sameContentAs', () {
    test('null and empty optionals are the same', () {
      expect(
        fakeCompleteDraft(
          number: '',
        ).sameContentAs(fakeCompleteDraft(number: '  ')),
        isTrue,
      );
    });

    test('a masked zip and its digits are the same', () {
      final masked = const PostalAddressDraft().copyWith(zipCode: '72120120');

      expect(masked.sameContentAs(masked.withZipCode('72120-120')), isTrue);
    });

    test('trailing spaces on text are ignored', () {
      expect(
        fakeCompleteDraft(
          street: 'QND 12',
        ).sameContentAs(fakeCompleteDraft(street: 'QND 12 ')),
        isTrue,
      );
    });

    test('a different city token is different content', () {
      expect(
        fakeCompleteDraft().sameContentAs(
          fakeCompleteDraft(cityToken: 'city-sp'),
        ),
        isFalse,
      );
    });

    test('lock flags do not change the content', () {
      final locked = fakeCompleteDraft().copyWith(isNeighborhoodLocked: true);

      expect(locked.sameContentAs(fakeCompleteDraft()), isTrue);
    });
  });

  group('hydration from a saved address', () {
    test('normalizes the zip and locks the city', () {
      final draft = PostalAddressDraft.fromParts(
        zipCode: '72120-120',
        cityToken: 'city-brasilia',
        cityName: 'Brasília',
        uf: 'DF',
        street: 'QND 12',
        neighborhood: 'Taguatinga',
        number: '10',
        complement: null,
      );

      expect(draft.zipCode, '72120120');
      expect(draft.complement, '');
      expect(draft.isCityLocked, isTrue);
      expect(draft.isNeighborhoodLocked, isFalse);
      expect(draft.isZipCodeUnknown, isFalse);
    });

    test('null parts become an empty draft', () {
      expect(PostalAddressDraft.fromParts().isBlank, isTrue);
    });
  });

  group('CEP lookup 200', () {
    test('applies city and uf and locks the city', () {
      final draft = const PostalAddressDraft().withCepLookup(
        cityToken: 'city-brasilia',
        cityName: 'Brasília',
        uf: 'DF',
        street: 'QND 12',
        neighborhood: 'Taguatinga',
      );

      expect(draft.cityToken, 'city-brasilia');
      expect(draft.cityName, 'Brasília');
      expect(draft.uf, 'DF');
      expect(draft.isCityLocked, isTrue);
    });

    test('replaces street and neighborhood instead of merging', () {
      final draft = const PostalAddressDraft()
          .withStreet('Rua digitada')
          .withNeighborhood('Bairro digitado')
          .withCepLookup(
            cityToken: 'city-brasilia',
            cityName: 'Brasília',
            uf: 'DF',
            street: 'QND 12',
            neighborhood: 'Taguatinga',
          );

      expect(draft.street, 'QND 12');
      expect(draft.neighborhood, 'Taguatinga');
    });

    test('a generic CEP replaces street and neighborhood by empty', () {
      final draft = const PostalAddressDraft()
          .withStreet('Rua digitada')
          .withNeighborhood('Bairro digitado')
          .withCepLookup(
            cityToken: 'city-brasilia',
            cityName: 'Brasília',
            uf: 'DF',
          );

      expect(draft.street, '');
      expect(draft.neighborhood, '');
      expect(draft.isNeighborhoodLocked, isFalse);
    });

    test('locks the neighborhood only when the lookup brought one', () {
      final withNeighborhood = const PostalAddressDraft().withCepLookup(
        cityToken: 'c',
        cityName: 'Brasília',
        uf: 'DF',
        neighborhood: 'Taguatinga',
      );
      final blankNeighborhood = const PostalAddressDraft().withCepLookup(
        cityToken: 'c',
        cityName: 'Brasília',
        uf: 'DF',
        neighborhood: '   ',
      );

      expect(withNeighborhood.isNeighborhoodLocked, isTrue);
      expect(blankNeighborhood.isNeighborhoodLocked, isFalse);
      expect(blankNeighborhood.neighborhood, '');
    });

    test('street and neighborhood from the lookup respect the caps', () {
      final draft = const PostalAddressDraft().withCepLookup(
        cityToken: 'c',
        cityName: 'Brasília',
        uf: 'DF',
        street: 'a' * 300,
        neighborhood: 'b' * 200,
      );

      expect(draft.street.length, PostalAddressLimits.street);
      expect(draft.neighborhood.length, PostalAddressLimits.neighborhood);
    });

    test('never touches number and complement', () {
      final draft = const PostalAddressDraft()
          .withNumber('10')
          .withComplement('Casa 2')
          .withCepLookup(cityToken: 'c', cityName: 'Brasília', uf: 'DF');

      expect(draft.number, '10');
      expect(draft.complement, 'Casa 2');
    });

    test('locks again after a picker choice when a new lookup succeeds', () {
      final draft = const PostalAddressDraft()
          .unlockCity()
          .withCity(token: 'c', name: 'Brasília', uf: 'DF')
          .withCepLookup(cityToken: 'c2', cityName: 'Santos', uf: 'SP');

      expect(draft.isCityLocked, isTrue);
      expect(draft.cityToken, 'c2');
    });
  });

  group('CEP lookup failure', () {
    PostalAddressDraft lookedUp() {
      return const PostalAddressDraft()
          .withZipCode('70040010')
          .withNumber('10')
          .withComplement('Casa 2')
          .withCepLookup(
            cityToken: 'city-brasilia',
            cityName: 'Brasília',
            uf: 'DF',
            street: 'QND 12',
            neighborhood: 'Taguatinga',
          );
    }

    test('unavailable unlocks the city and clears what the lookup brought', () {
      final draft = lookedUp().withCepUnavailable();

      expect(draft.cityToken, '');
      expect(draft.cityName, '');
      expect(draft.uf, '');
      expect(draft.street, '');
      expect(draft.neighborhood, '');
      expect(draft.isCityLocked, isFalse);
      expect(draft.isNeighborhoodLocked, isFalse);
      expect(draft.isZipCodeUnknown, isFalse);
    });

    test('unavailable keeps zip, number and complement', () {
      final draft = lookedUp().withCepUnavailable();

      expect(draft.zipCode, '70040010');
      expect(draft.number, '10');
      expect(draft.complement, 'Casa 2');
    });

    test('unknown does the same and blocks saving until the zip changes', () {
      final draft = lookedUp().withCepUnknown();

      expect(draft.cityToken, '');
      expect(draft.isCityLocked, isFalse);
      expect(draft.isZipCodeUnknown, isTrue);
      expect(draft.zipCode, '70040010');
    });
  });

  group('picker', () {
    test('choosing a uf clears the city and unlocks the picker', () {
      final draft = fakeCompleteDraft().withUf('SP');

      expect(draft.uf, 'SP');
      expect(draft.cityToken, '');
      expect(draft.cityName, '');
      expect(draft.isCityLocked, isFalse);
      expect(draft.isComplete, isFalse);
    });

    test('choosing a uf keeps the street', () {
      expect(fakeCompleteDraft().withUf('SP').street, 'QND 12');
    });

    test('choosing a city sets token, name and uf', () {
      final draft = const PostalAddressDraft()
          .withUf('DF')
          .withCity(token: 'city-brasilia', name: 'Brasília', uf: 'DF');

      expect(draft.cityToken, 'city-brasilia');
      expect(draft.cityName, 'Brasília');
      expect(draft.uf, 'DF');
      expect(draft.isCityLocked, isFalse);
    });

    test('neither uf nor city choice clears the unknown-CEP block', () {
      final unknown = fakeCompleteDraft().withCepUnknown();

      final afterPicker = unknown
          .withUf('DF')
          .withCity(token: 'city-brasilia', name: 'Brasília', uf: 'DF');

      expect(afterPicker.isZipCodeUnknown, isTrue);
    });

    test('unlockCity frees a locked city without touching data', () {
      final draft = PostalAddressDraft.fromParts(
        zipCode: '72120120',
        cityToken: 'city-brasilia',
        cityName: 'Brasília',
        uf: 'DF',
        street: 'QND 12',
      ).unlockCity();

      expect(draft.isCityLocked, isFalse);
      expect(draft.cityToken, 'city-brasilia');
    });

    test('a draft without a city is never locked', () {
      expect(const PostalAddressDraft().isCityLocked, isFalse);
    });
  });
}
