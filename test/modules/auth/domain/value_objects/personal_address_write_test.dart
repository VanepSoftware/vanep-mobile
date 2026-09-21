import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';

import '../../../../core/domain/postal_address_draft_fixture.dart';

void main() {
  test('a savable draft becomes a write with the required postal fields', () {
    final write = personalAddressWriteFromDraft(fakeCompleteDraft());

    expect(write?.cityToken, 'city-brasilia');
    expect(write?.street, 'QND 12');
    expect(write?.zipCode, '72120120');
  });

  test('optionals that were never filled stay null', () {
    final write = personalAddressWriteFromDraft(fakeCompleteDraft());

    expect(write?.number, isNull);
    expect(write?.complement, isNull);
    expect(write?.neighborhood, isNull);
  });

  test('filled optionals and the street are trimmed', () {
    final write = personalAddressWriteFromDraft(
      fakeCompleteDraft(
        street: '  QND 12 ',
        number: ' 10 ',
        complement: 'Casa 2',
        neighborhood: 'Taguatinga',
      ),
    );

    expect(write?.street, 'QND 12');
    expect(write?.number, '10');
    expect(write?.complement, 'Casa 2');
    expect(write?.neighborhood, 'Taguatinga');
  });

  test('blank optionals become null', () {
    final write = personalAddressWriteFromDraft(
      fakeCompleteDraft(number: '  ', complement: '', neighborhood: ' '),
    );

    expect(write?.number, isNull);
    expect(write?.complement, isNull);
    expect(write?.neighborhood, isNull);
  });

  test('a masked zip is written as eight digits', () {
    final draft = fakeCompleteDraft().withZipCode('72120-120');

    expect(personalAddressWriteFromDraft(draft)?.zipCode, '72120120');
  });

  test('an incomplete draft never becomes a write', () {
    expect(personalAddressWriteFromDraft(const PostalAddressDraft()), isNull);
    expect(
      personalAddressWriteFromDraft(fakeCompleteDraft(zipCode: '7212012')),
      isNull,
    );
    expect(
      personalAddressWriteFromDraft(fakeCompleteDraft(cityToken: '')),
      isNull,
    );
  });

  test('a complete draft whose CEP is unknown never becomes a write', () {
    final draft = fakeCompleteDraft().copyWith(isZipCodeUnknown: true);

    expect(personalAddressWriteFromDraft(draft), isNull);
  });

  test('writes with the same fields are equal', () {
    expect(
      personalAddressWriteFromDraft(fakeCompleteDraft()),
      personalAddressWriteFromDraft(fakeCompleteDraft()),
    );
  });
}
