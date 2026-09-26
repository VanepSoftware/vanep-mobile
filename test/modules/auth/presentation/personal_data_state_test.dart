import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../auth_fixtures.dart';
import '../personal_address_fixture.dart';
import 'personal_data_fixture.dart';

void main() {
  group('profile dirty', () {
    test('a clean snapshot is not dirty', () {
      final state = readyState(address: fakePersonalAddress());

      expect(state.isProfileDirty, isFalse);
      expect(state.isAddressDirty, isFalse);
      expect(state.canSave, isFalse);
    });

    test('changing the name is profile dirty and enables save', () {
      final state = readyState().copyWith(draftName: 'Maria');

      expect(state.isProfileDirty, isTrue);
      expect(state.canSave, isTrue);
    });

    test('changing gender from female to omitted is profile dirty', () {
      final state = readyState().copyWith(clearDraftGender: true);

      expect(state.draftGender, isNull);
      expect(state.isProfileDirty, isTrue);
    });

    test('an omitted gender that stays omitted is not dirty', () {
      final state = readyState(profile: const FakeUserProfile(gender: null));

      expect(state.draftGender, isNull);
      expect(state.isProfileDirty, isFalse);
    });

    test('choosing a gender after omitting it is dirty', () {
      final state = readyState(
        profile: const FakeUserProfile(gender: null),
      ).copyWith(draftGender: Gender.male);

      expect(state.isProfileDirty, isTrue);
    });
  });

  group('address dirty and savable', () {
    test('an untouched saved house is not dirty', () {
      final state = readyState(address: fakePersonalAddress());

      expect(state.addressDraft, fakePersonalAddress().toDraft());
      expect(state.isAddressDirty, isFalse);
    });

    test('changing the number of a saved house enables save', () {
      final address = fakePersonalAddress();
      final state = readyState(
        address: address,
        addressDraft: address.toDraft().withNumber('99'),
      );

      expect(state.isAddressDirty, isTrue);
      expect(state.isAddressSavable, isTrue);
      expect(state.canSave, isTrue);
    });

    test('a complete draft without a saved house enables save', () {
      final state = readyState(addressDraft: fakeCompleteDraft());

      expect(state.isAddressDirty, isTrue);
      expect(state.isAddressSavable, isTrue);
      expect(state.canSave, isTrue);
    });

    test('number, complement and neighborhood alone do not enable save', () {
      final state = readyState(
        addressDraft: const PostalAddressDraft()
            .withNumber('10')
            .withComplement('Casa 2')
            .withNeighborhood('Taguatinga'),
      );

      expect(state.isAddressDirty, isTrue);
      expect(state.isAddressSavable, isFalse);
      expect(state.canSave, isFalse);
    });

    test('a city and street with a short zip do not enable save', () {
      final state = readyState(
        addressDraft: fakeCompleteDraft(zipCode: '7212012'),
      );

      expect(state.isAddressSavable, isFalse);
    });

    test('a CEP the lookup says does not exist blocks save', () {
      final state = readyState(
        addressDraft: fakeCompleteDraft().copyWith(isZipCodeUnknown: true),
      );

      expect(state.isAddressSavable, isFalse);
      expect(state.canSave, isFalse);
    });

    test('a manual fallback after a city outside the catalog still saves', () {
      final state = readyState(
        addressDraft: const PostalAddressDraft()
            .withZipCode('70040010')
            .withCepUnavailable()
            .withUf('DF')
            .withCity(token: 'city-brasilia', name: 'Brasília', uf: 'DF')
            .withStreet('QND 12'),
      ).copyWith(cepFailure: CepFailure.cityNotInCatalog);

      expect(state.isAddressSavable, isTrue);
    });

    test('null and empty optionals are the same for address dirty', () {
      final address = fakePersonalAddress(number: null);
      final state = readyState(
        address: address,
        addressDraft: address.toDraft().withNumber(''),
      );

      expect(state.isAddressDirty, isFalse);
    });

    test('a saved house locks the municipality until the picker frees it', () {
      final state = readyState(address: fakePersonalAddress());

      expect(state.addressDraft.isCityLocked, isTrue);
      expect(
        state
            .copyWith(addressDraft: state.addressDraft.unlockCity())
            .addressDraft
            .isCityLocked,
        isFalse,
      );
    });
  });

  group('save gating', () {
    test('cannot save while not ready', () {
      final state = stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.saving,
      ).copyWith(draftName: 'Maria');

      expect(state.canSave, isFalse);
    });

    test('a dirty profile alone enables save with a blank address', () {
      final state = readyState().copyWith(draftName: 'Maria');

      expect(state.isAddressDirty, isFalse);
      expect(state.canSave, isTrue);
    });
  });
}
