import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/personal_address.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/personal_address_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/personal_address_write.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';

import '../../../core/domain/postal_address_draft_fixture.dart';
import '../../ibge_locations/ibge_locations_fixture.dart';
import '../../ibge_locations/ibge_locations_mocks.dart';
import '../auth_fixtures.dart';
import '../auth_mocks.dart';
import '../personal_address_fixture.dart';
import 'auth_presentation_mocks.dart';
import 'personal_data_fixture.dart';

const cepLookupTestWait = Duration(milliseconds: 20);

void main() {
  late MockRefreshUserProfile refreshUserProfile;
  late MockPatchUserProfile patchUserProfile;
  late MockRequestEmailChange requestEmailChange;
  late MockFindMyPersonalAddress findMyPersonalAddress;
  late MockUpsertMyPersonalAddress upsertMyPersonalAddress;
  late MockDeleteMyPersonalAddress deleteMyPersonalAddress;
  late MockLookupCep lookupCep;
  late MockListStates listStates;
  late MockListCities listCities;
  late List<UserProfile> syncedProfiles;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    refreshUserProfile = MockRefreshUserProfile();
    patchUserProfile = MockPatchUserProfile();
    requestEmailChange = MockRequestEmailChange();
    findMyPersonalAddress = MockFindMyPersonalAddress();
    upsertMyPersonalAddress = MockUpsertMyPersonalAddress();
    deleteMyPersonalAddress = MockDeleteMyPersonalAddress();
    lookupCep = MockLookupCep();
    listStates = MockListStates();
    listCities = MockListCities();
    syncedProfiles = [];
    when(findMyPersonalAddress.call).thenAnswer(
      (_) async => const Ok<PersonalAddressFailure, PersonalAddress?>(null),
    );
    when(() => listStates()).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: const <BrazilianState>[])),
    );
    when(() => listCities(uf: any(named: 'uf'))).thenAnswer(
      (_) async => Ok(fakeIbgeLocationsPage(items: <BrazilianCity>[])),
    );
  });

  PersonalDataCubit buildCubit() => PersonalDataCubit(
    refreshUserProfile: refreshUserProfile,
    patchUserProfile: patchUserProfile,
    requestEmailChange: requestEmailChange,
    findMyPersonalAddress: findMyPersonalAddress,
    upsertMyPersonalAddress: upsertMyPersonalAddress,
    deleteMyPersonalAddress: deleteMyPersonalAddress,
    lookupCep: lookupCep,
    listStates: listStates,
    listCities: listCities,
    syncProfile: syncedProfiles.add,
    cepLookupDebounce: Duration.zero,
  );

  void profileRefreshes([UserProfile profile = const FakeUserProfile()]) {
    when(
      refreshUserProfile.call,
    ).thenAnswer((_) async => Ok<ProfileEditFailure, UserProfile>(profile));
  }

  group('load', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'emits loading then ready with profile drafts and no house',
      setUp: profileRefreshes,
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PersonalDataState(status: PersonalDataStatus.loading),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.draftName, 'draftName', 'Ana Motorista')
            .having((s) => s.draftPhone, 'draftPhone', '11999999999')
            .having((s) => s.draftGender, 'draftGender', Gender.female)
            .having((s) => s.address, 'address', isNull)
            .having((s) => s.addressDraft.isBlank, 'blank draft', isTrue)
            .having((s) => s.isDirty, 'isDirty', false)
            .having((s) => s.canSave, 'canSave', isFalse),
      ],
      verify: (_) {
        verify(refreshUserProfile.call).called(1);
        verify(findMyPersonalAddress.call).called(1);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'loads profile and house together and hydrates the draft',
      setUp: () {
        profileRefreshes();
        when(findMyPersonalAddress.call).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress?>(
            fakePersonalAddress(zipCode: '72120-120'),
          ),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PersonalDataState(status: PersonalDataStatus.loading),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having(
              (s) => s.address,
              'address',
              fakePersonalAddress(zipCode: '72120-120'),
            )
            .having((s) => s.addressDraft.cityToken, 'city', 'city-brasilia')
            .having((s) => s.addressDraft.zipCode, 'zip digits', '72120120')
            .having((s) => s.addressDraft.street, 'street', 'QND 12')
            .having((s) => s.addressDraft.number, 'number', '10')
            .having((s) => s.isMunicipalityLocked, 'locked', isTrue)
            .having((s) => s.isDirty, 'isDirty', false),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'emits loadFailed on profile refresh error',
      setUp: () => when(refreshUserProfile.call).thenAnswer(
        (_) async => const Err<ProfileEditFailure, UserProfile>(
          NetworkProfileEditFailure(),
        ),
      ),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PersonalDataState(status: PersonalDataStatus.loading),
        const PersonalDataState(status: PersonalDataStatus.loadFailed),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'emits loadFailed when the house find fails',
      setUp: () {
        profileRefreshes();
        when(findMyPersonalAddress.call).thenAnswer(
          (_) async => const Err<PersonalAddressFailure, PersonalAddress?>(
            PersonalAddressFailure.network,
          ),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PersonalDataState(status: PersonalDataStatus.loading),
        const PersonalDataState(status: PersonalDataStatus.loadFailed),
      ],
    );
  });

  group('drafts and profile save', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'updatePhone stores only digits from a masked value',
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.updatePhone('(11) 98888-7777'),
      expect: () => [
        isA<PersonalDataState>()
            .having((s) => s.draftPhone, 'draftPhone', '11988887777')
            .having((s) => s.isDirty, 'isDirty', true),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'updateName marks dirty and clears the name field error',
      build: buildCubit,
      seed: () => readyState().copyWith(
        fieldErrors: const {'name': ProfileErrorCode.fieldNull},
      ),
      act: (cubit) => cubit.updateName('Maria'),
      expect: () => [
        isA<PersonalDataState>()
            .having((s) => s.draftName, 'draftName', 'Maria')
            .having((s) => s.isDirty, 'isDirty', true)
            .having((s) => s.fieldErrors, 'fieldErrors', isEmpty),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'updateGender(null) omits the gender',
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.updateGender(null),
      expect: () => [
        isA<PersonalDataState>()
            .having((s) => s.draftGender, 'draftGender', isNull)
            .having((s) => s.isProfileDirty, 'profile dirty', isTrue),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'save patches only changed fields and syncs the profile',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(name: 'Maria'),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState().copyWith(draftName: 'Maria'),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.draftName, 'draftName', 'Maria')
            .having((s) => s.isDirty, 'isDirty', false)
            .having(
              (s) => s.feedback,
              'feedback',
              const PersonalDataSaveSuccessFeedback(),
            ),
      ],
      verify: (_) {
        final captured =
            verify(() => patchUserProfile(captureAny())).captured.single
                as ProfilePatchRequest;
        expect(captured.includesName, isTrue);
        expect(captured.name, 'Maria');
        expect(captured.includesPhone, isFalse);
        expect(captured.includesGender, isFalse);
        expect(syncedProfiles.single.name, 'Maria');
        verifyNever(() => upsertMyPersonalAddress(any()));
        verifyNever(refreshUserProfile.call);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'save does nothing when nothing is dirty',
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.save(),
      expect: () => <PersonalDataState>[],
      verify: (_) {
        verifyNever(() => patchUserProfile(any()));
        verifyNever(() => upsertMyPersonalAddress(any()));
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'save maps structured field errors',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Err<ProfileEditFailure, UserProfile>(
            StructuredProfileEditFailure(
              code: ProfileErrorCode.phoneBlank,
              field: 'phone',
            ),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState().copyWith(draftPhone: ''),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.fieldErrors, 'fieldErrors', {
              'phone': ProfileErrorCode.phoneBlank,
            })
            .having(
              (s) => s.feedback,
              'feedback',
              const PersonalDataFailureFeedback(
                StructuredProfileEditFailure(
                  code: ProfileErrorCode.phoneBlank,
                  field: 'phone',
                ),
              ),
            ),
      ],
      verify: (_) => expect(syncedProfiles, isEmpty),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'omitting the gender patches gender as JSON null',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(gender: null),
          ),
        );
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) {
        cubit.updateGender(null);
        return cubit.save();
      },
      verify: (_) {
        final captured =
            verify(() => patchUserProfile(captureAny())).captured.single
                as ProfilePatchRequest;
        expect(captured.includesGender, isTrue);
        expect(captured.gender, isNull);
        expect(captured.toJsonMap(), {'gender': null});
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'does not patch gender when it is already omitted',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(name: 'Maria', gender: null),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        profile: const FakeUserProfile(gender: null),
      ).copyWith(draftName: 'Maria'),
      act: (cubit) => cubit.save(),
      verify: (_) {
        final captured =
            verify(() => patchUserProfile(captureAny())).captured.single
                as ProfilePatchRequest;
        expect(captured.includesGender, isFalse);
        expect(captured.toJsonMap().containsKey('gender'), isFalse);
      },
    );
  });

  group('save house', () {
    PersonalAddressWrite expectedWrite({String? number = '10'}) {
      return PersonalAddressWrite(
        cityToken: 'city-brasilia',
        street: 'QND 12',
        zipCode: '72120120',
        number: number,
        complement: 'Casa 2',
        neighborhood: 'Taguatinga',
      );
    }

    PostalAddressDraft filledDraft() => fakeCompleteDraft(
      neighborhood: 'Taguatinga',
      number: '10',
      complement: 'Casa 2',
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'saves only a savable house without patching the profile',
      setUp: () {
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress>(
            fakePersonalAddress(),
          ),
        );
        profileRefreshes();
      },
      build: buildCubit,
      seed: () => readyState(addressDraft: filledDraft()),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.address, 'address', fakePersonalAddress())
            .having((s) => s.isAddressDirty, 'isAddressDirty', false)
            .having(
              (s) => s.feedback,
              'feedback',
              const PersonalDataSaveSuccessFeedback(),
            ),
      ],
      verify: (_) {
        expect(
          verify(() => upsertMyPersonalAddress(captureAny())).captured.single,
          expectedWrite(),
        );
        verifyNever(() => patchUserProfile(any()));
        verify(refreshUserProfile.call).called(1);
        expect(syncedProfiles, hasLength(1));
        verifyNever(deleteMyPersonalAddress.call);
        verifyNever(findMyPersonalAddress.call);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'resends unchanged optionals and nulls the emptied ones on replace',
      setUp: () {
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress>(
            fakePersonalAddress(complement: null),
          ),
        );
        profileRefreshes();
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
        addressDraft: fakePersonalAddress().toDraft().withComplement(''),
      ),
      act: (cubit) => cubit.save(),
      verify: (_) {
        expect(
          verify(() => upsertMyPersonalAddress(captureAny())).captured.single,
          const PersonalAddressWrite(
            cityToken: 'city-brasilia',
            street: 'QND 12',
            zipCode: '72120120',
            number: '10',
            neighborhood: 'Taguatinga',
          ),
        );
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'patches the profile then puts the house when both are dirty',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(name: 'Maria'),
          ),
        );
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress>(
            fakePersonalAddress(),
          ),
        );
        profileRefreshes(const FakeUserProfile(name: 'Maria'));
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
        addressDraft: fakePersonalAddress().toDraft().withNumber('99'),
      ).copyWith(draftName: 'Maria'),
      act: (cubit) => cubit.save(),
      verify: (_) {
        verifyInOrder([
          () => patchUserProfile(any()),
          () => upsertMyPersonalAddress(any()),
          refreshUserProfile.call,
        ]);
      },
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>().having(
          (s) => s.feedback,
          'feedback',
          const PersonalDataSaveSuccessFeedback(),
        ),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'does not put the house when the profile patch fails',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Err<ProfileEditFailure, UserProfile>(
            NetworkProfileEditFailure(),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
        addressDraft: fakePersonalAddress().toDraft().withNumber('99'),
      ).copyWith(draftName: 'Maria'),
      act: (cubit) => cubit.save(),
      verify: (cubit) {
        verifyNever(() => upsertMyPersonalAddress(any()));
        expect(cubit.state.feedback, isA<PersonalDataFailureFeedback>());
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'keeps the house draft when the put fails after a good patch',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(name: 'Maria'),
          ),
        );
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => const Err<PersonalAddressFailure, PersonalAddress>(
            PersonalAddressFailure.cityNotFound,
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
        addressDraft: fakePersonalAddress().toDraft().withNumber('99'),
      ).copyWith(draftName: 'Maria'),
      act: (cubit) => cubit.save(),
      verify: (cubit) {
        expect(syncedProfiles.single.name, 'Maria');
        expect(cubit.state.addressDraft.number, '99');
        expect(cubit.state.isAddressDirty, isTrue);
        expect(
          cubit.state.feedback,
          const PersonalDataAddressSaveFailureFeedback(
            PersonalAddressFailure.cityNotFound,
          ),
        );
        verifyNever(refreshUserProfile.call);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'a 400 from the back keeps the draft and reports a validation failure',
      setUp: () {
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => const Err<PersonalAddressFailure, PersonalAddress>(
            PersonalAddressFailure.validation,
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(addressDraft: filledDraft()),
      act: (cubit) => cubit.save(),
      verify: (cubit) {
        expect(
          cubit.state.feedback,
          const PersonalDataAddressSaveFailureFeedback(
            PersonalAddressFailure.validation,
          ),
        );
        expect(cubit.state.addressDraft, filledDraft());
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'still reports success when only the onboarding refresh fails',
      setUp: () {
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress>(
            fakePersonalAddress(),
          ),
        );
        when(refreshUserProfile.call).thenAnswer(
          (_) async => const Err<ProfileEditFailure, UserProfile>(
            NetworkProfileEditFailure(),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(addressDraft: filledDraft()),
      act: (cubit) => cubit.save(),
      verify: (cubit) {
        expect(cubit.state.feedback, const PersonalDataSaveSuccessFeedback());
        expect(cubit.state.address, fakePersonalAddress());
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'does not put an incomplete house',
      build: buildCubit,
      seed: () => readyState(addressDraft: fakeCompleteDraft(street: '')),
      act: (cubit) => cubit.save(),
      expect: () => <PersonalDataState>[],
      verify: (_) => verifyNever(() => upsertMyPersonalAddress(any())),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'does not put a house whose CEP the lookup says does not exist',
      build: buildCubit,
      seed: () => readyState(
        addressDraft: fakeCompleteDraft().copyWith(isZipCodeUnknown: true),
      ),
      act: (cubit) => cubit.save(),
      expect: () => <PersonalDataState>[],
      verify: (_) => verifyNever(() => upsertMyPersonalAddress(any())),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'writes a masked zip as eight digits',
      setUp: () {
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress>(
            fakePersonalAddress(),
          ),
        );
        profileRefreshes();
        when(
          () => lookupCep(any()),
        ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(fakeCepLookup()));
      },
      build: buildCubit,
      seed: () => readyState(addressDraft: fakeCompleteDraft(zipCode: '')),
      act: (cubit) async {
        cubit.updateZipCode('72120-120');
        await Future<void>.delayed(cepLookupTestWait);
        await cubit.save();
      },
      verify: (_) {
        final write =
            verify(() => upsertMyPersonalAddress(captureAny())).captured.single
                as PersonalAddressWrite;
        expect(write.zipCode, '72120120');
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'save never deletes the house',
      setUp: () {
        when(() => upsertMyPersonalAddress(any())).thenAnswer(
          (_) async => Ok<PersonalAddressFailure, PersonalAddress>(
            fakePersonalAddress(),
          ),
        );
        profileRefreshes();
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
        addressDraft: fakePersonalAddress().toDraft().withNumber('99'),
      ),
      act: (cubit) => cubit.save(),
      verify: (_) => verifyNever(deleteMyPersonalAddress.call),
    );
  });

  group('clear house', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'deletes the saved house and clears snapshot and draft',
      setUp: () {
        when(
          deleteMyPersonalAddress.call,
        ).thenAnswer((_) async => const Ok<PersonalAddressFailure, void>(null));
        profileRefreshes();
      },
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.clearAddress(),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.address, 'address', isNull)
            .having((s) => s.addressDraft.isBlank, 'blank draft', isTrue)
            .having(
              (s) => s.feedback,
              'feedback',
              const PersonalDataAddressClearedFeedback(),
            ),
      ],
      verify: (_) {
        verify(deleteMyPersonalAddress.call).called(1);
        verify(refreshUserProfile.call).called(1);
        expect(syncedProfiles, hasLength(1));
        verifyNever(() => upsertMyPersonalAddress(any()));
        verifyNever(findMyPersonalAddress.call);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'keeps unsaved profile edits when the house is cleared',
      setUp: () {
        when(
          deleteMyPersonalAddress.call,
        ).thenAnswer((_) async => const Ok<PersonalAddressFailure, void>(null));
        profileRefreshes();
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
      ).copyWith(draftName: 'Maria digitando'),
      act: (cubit) => cubit.clearAddress(),
      verify: (cubit) {
        expect(cubit.state.draftName, 'Maria digitando');
        expect(cubit.state.isProfileDirty, isTrue);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'still clears the house when only the onboarding refresh fails',
      setUp: () {
        when(
          deleteMyPersonalAddress.call,
        ).thenAnswer((_) async => const Ok<PersonalAddressFailure, void>(null));
        when(refreshUserProfile.call).thenAnswer(
          (_) async => const Err<ProfileEditFailure, UserProfile>(
            NetworkProfileEditFailure(),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.clearAddress(),
      verify: (cubit) {
        expect(cubit.state.address, isNull);
        expect(
          cubit.state.feedback,
          const PersonalDataAddressClearedFeedback(),
        );
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'keeps the snapshot when the delete fails',
      setUp: () {
        when(deleteMyPersonalAddress.call).thenAnswer(
          (_) async => const Err<PersonalAddressFailure, void>(
            PersonalAddressFailure.network,
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.clearAddress(),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.address, 'address', fakePersonalAddress())
            .having(
              (s) => s.feedback,
              'feedback',
              const PersonalDataAddressFailureFeedback(
                PersonalAddressFailure.network,
              ),
            ),
      ],
      verify: (_) {
        verifyNever(refreshUserProfile.call);
        expect(syncedProfiles, isEmpty);
      },
    );
  });

  group('cep lookup', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'looks up eight digits after the debounce and strips the hyphen',
      setUp: () {
        when(
          () => lookupCep(any()),
        ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(fakeCepLookup()));
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.updateZipCode('70040-010'),
      wait: cepLookupTestWait,
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.addressDraft.zipCode,
          'zip',
          '70040010',
        ),
        isA<PersonalDataState>()
            .having((s) => s.addressDraft.cityToken, 'city', 'city-brasilia')
            .having((s) => s.addressDraft.cityName, 'name', 'Brasília')
            .having((s) => s.addressDraft.uf, 'uf', 'DF')
            .having((s) => s.addressDraft.street, 'street', 'QND 12')
            .having(
              (s) => s.addressDraft.neighborhood,
              'neighborhood',
              'Taguatinga',
            )
            .having((s) => s.addressDraft.number, 'number', '')
            .having((s) => s.isMunicipalityLocked, 'city locked', isTrue)
            .having(
              (s) => s.addressDraft.isNeighborhoodLocked,
              'neighborhood locked',
              isTrue,
            ),
      ],
      verify: (_) => verify(() => lookupCep('70040010')).called(1),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'replaces street and neighborhood even when the lookup omits them',
      setUp: () {
        when(() => lookupCep(any())).thenAnswer(
          (_) async => Ok<CepFailure, CepLookup>(
            fakeCepLookup(street: null, neighborhood: null),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        addressDraft: const PostalAddressDraft()
            .withStreet('Rua digitada')
            .withNeighborhood('Bairro digitado')
            .withNumber('10'),
      ),
      act: (cubit) => cubit.updateZipCode('70040010'),
      wait: cepLookupTestWait,
      verify: (cubit) {
        expect(cubit.state.addressDraft.street, '');
        expect(cubit.state.addressDraft.neighborhood, '');
        expect(cubit.state.addressDraft.isNeighborhoodLocked, isFalse);
        expect(cubit.state.addressDraft.number, '10');
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'a new CEP 200 overwrites what the previous lookup brought',
      setUp: () {
        when(() => lookupCep(any())).thenAnswer(
          (_) async => Ok<CepFailure, CepLookup>(
            fakeCepLookup(
              cityToken: 'city-santos',
              cityName: 'Santos',
              uf: 'SP',
              street: 'Av. Ana Costa',
              neighborhood: 'Gonzaga',
            ),
          ),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        address: fakePersonalAddress(),
        addressDraft: fakePersonalAddress().toDraft().unlockCity(),
      ),
      act: (cubit) => cubit.updateZipCode('11060-002'),
      wait: cepLookupTestWait,
      verify: (cubit) {
        final draft = cubit.state.addressDraft;
        expect(draft.cityToken, 'city-santos');
        expect(draft.uf, 'SP');
        expect(draft.street, 'Av. Ana Costa');
        expect(draft.neighborhood, 'Gonzaga');
        expect(draft.isCityLocked, isTrue);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'marks a CEP that does not exist and blocks save',
      setUp: () {
        when(() => lookupCep(any())).thenAnswer(
          (_) async => const Err<CepFailure, CepLookup>(CepFailure.notFound),
        );
      },
      build: buildCubit,
      seed: () =>
          readyState(addressDraft: const PostalAddressDraft().withNumber('10')),
      act: (cubit) => cubit.updateZipCode('00000000'),
      wait: cepLookupTestWait,
      verify: (cubit) {
        final state = cubit.state;
        expect(state.cepFailure, CepFailure.notFound);
        expect(state.addressDraft.isZipCodeUnknown, isTrue);
        expect(state.addressDraft.zipCode, '00000000');
        expect(state.addressDraft.number, '10');
        expect(state.addressDraft.cityToken, '');
        expect(state.isMunicipalityLocked, isFalse);
        expect(state.isAddressSavable, isFalse);
        verify(() => listStates()).called(1);
      },
    );

    for (final failure in [
      CepFailure.cityNotInCatalog,
      CepFailure.rateLimited,
      CepFailure.unavailable,
      CepFailure.network,
      CepFailure.unexpected,
    ]) {
      blocTest<PersonalDataCubit, PersonalDataState>(
        '${failure.name} clears the lookup data and opens the picker',
        setUp: () {
          when(
            () => lookupCep(any()),
          ).thenAnswer((_) async => Err<CepFailure, CepLookup>(failure));
        },
        build: buildCubit,
        seed: () => readyState(
          address: fakePersonalAddress(),
          addressDraft: fakePersonalAddress().toDraft().unlockCity(),
        ),
        act: (cubit) => cubit.updateZipCode('70040010'),
        wait: cepLookupTestWait,
        verify: (cubit) {
          final state = cubit.state;
          expect(state.cepFailure, failure);
          expect(state.addressDraft.isZipCodeUnknown, isFalse);
          expect(state.addressDraft.zipCode, '70040010');
          expect(state.addressDraft.cityToken, '');
          expect(state.addressDraft.street, '');
          expect(state.addressDraft.neighborhood, '');
          expect(state.addressDraft.number, '10');
          expect(state.addressDraft.complement, 'Casa 2');
          expect(state.isMunicipalityLocked, isFalse);
          verify(() => listStates()).called(1);
        },
      );
    }

    blocTest<PersonalDataCubit, PersonalDataState>(
      'a format failure only records the failure',
      setUp: () {
        when(() => lookupCep(any())).thenAnswer(
          (_) async =>
              const Err<CepFailure, CepLookup>(CepFailure.invalidFormat),
        );
      },
      build: buildCubit,
      seed: () => readyState(addressDraft: fakeCompleteDraft()),
      act: (cubit) => cubit.updateZipCode('70040010'),
      wait: cepLookupTestWait,
      verify: (cubit) {
        expect(cubit.state.cepFailure, CepFailure.invalidFormat);
        expect(cubit.state.addressDraft.cityToken, 'city-brasilia');
        verifyNever(() => listStates());
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'does not look up seven digits',
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.updateZipCode('7004001'),
      wait: cepLookupTestWait,
      verify: (_) => verifyNever(() => lookupCep(any())),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'shortening the CEP of a saved house frees the picker without a lookup',
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.updateZipCode('7212012'),
      wait: cepLookupTestWait,
      verify: (cubit) {
        expect(cubit.state.isMunicipalityLocked, isFalse);
        expect(cubit.state.addressDraft.cityToken, 'city-brasilia');
        verifyNever(() => lookupCep(any()));
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'typing a new CEP clears the previous failure',
      build: buildCubit,
      seed: () => readyState().copyWith(cepFailure: CepFailure.rateLimited),
      act: (cubit) => cubit.updateZipCode('7004'),
      verify: (cubit) => expect(cubit.state.cepFailure, isNull),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'street, neighborhood, number and complement update the draft',
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit
        ..updateStreet('QND 12 ')
        ..updateNeighborhood('Taguatinga')
        ..updateNumber('10')
        ..updateComplement('Casa 2'),
      verify: (cubit) {
        final draft = cubit.state.addressDraft;
        expect(draft.street, 'QND 12 ');
        expect(draft.neighborhood, 'Taguatinga');
        expect(draft.number, '10');
        expect(draft.complement, 'Casa 2');
      },
    );
  });

  group('city picker', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'opening the picker lists states, not cities, and frees the city',
      setUp: () {
        when(() => listStates()).thenAnswer(
          (_) async => Ok(fakeIbgeLocationsPage(items: [fakeDfState])),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        addressDraft: const PostalAddressDraft().withStreet('QND 12'),
      ),
      act: (cubit) => cubit.openCityPicker(),
      verify: (cubit) {
        expect(cubit.state.catalogStates, [fakeDfState]);
        expect(cubit.state.addressDraft.isCityUnlocked, isTrue);
        verify(() => listStates()).called(1);
        verifyNever(() => listCities(uf: any(named: 'uf')));
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'opening the picker is ignored while a CEP lookup holds the city',
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.openCityPicker(),
      expect: () => <PersonalDataState>[],
      verify: (_) => verifyNever(() => listStates()),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'changing the uf clears the city token and lists that uf',
      setUp: () {
        when(() => listCities(uf: 'DF')).thenAnswer(
          (_) async => Ok(fakeIbgeLocationsPage(items: [fakeBrazilianCity()])),
        );
      },
      build: buildCubit,
      seed: () => readyState(addressDraft: fakeCompleteDraft().unlockCity()),
      act: (cubit) => cubit.selectUf('DF'),
      verify: (cubit) {
        expect(cubit.state.addressDraft.uf, 'DF');
        expect(cubit.state.addressDraft.cityToken, '');
        expect(cubit.state.catalogCities, [fakeBrazilianCity()]);
        expect(cubit.state.isAddressSavable, isFalse);
        verify(() => listCities(uf: 'DF')).called(1);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'choosing a city stores its token, name and uf',
      build: buildCubit,
      seed: () =>
          readyState(addressDraft: const PostalAddressDraft().withUf('DF')),
      act: (cubit) => cubit.selectCity(fakeBrazilianCity()),
      verify: (cubit) {
        expect(cubit.state.addressDraft.cityToken, 'city-brasilia');
        expect(cubit.state.addressDraft.cityName, 'Brasília');
        expect(cubit.state.addressDraft.uf, 'DF');
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'choosing a city clears a soft CEP failure',
      build: buildCubit,
      seed: () => readyState(
        addressDraft: const PostalAddressDraft().withCepUnavailable(),
      ).copyWith(cepFailure: CepFailure.rateLimited),
      act: (cubit) => cubit.selectCity(fakeBrazilianCity()),
      verify: (cubit) => expect(cubit.state.cepFailure, isNull),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'choosing a city after a CEP that does not exist keeps save blocked',
      build: buildCubit,
      seed: () => readyState(
        addressDraft: fakeCompleteDraft(
          cityToken: '',
          cityName: '',
          uf: '',
        ).withCepUnknown().withStreet('QND 12'),
      ).copyWith(cepFailure: CepFailure.notFound),
      act: (cubit) => cubit.selectCity(fakeBrazilianCity()),
      verify: (cubit) {
        expect(cubit.state.cepFailure, CepFailure.notFound);
        expect(cubit.state.addressDraft.isZipCodeUnknown, isTrue);
        expect(cubit.state.isAddressSavable, isFalse);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'changing the uf after a CEP that does not exist keeps the failure',
      setUp: () {
        when(() => listCities(uf: 'DF')).thenAnswer(
          (_) async => Ok(fakeIbgeLocationsPage(items: [fakeBrazilianCity()])),
        );
      },
      build: buildCubit,
      seed: () => readyState(
        addressDraft: const PostalAddressDraft()
            .withZipCode('00000000')
            .withCepUnknown(),
      ).copyWith(cepFailure: CepFailure.notFound),
      act: (cubit) => cubit.selectUf('DF'),
      verify: (cubit) {
        expect(cubit.state.cepFailure, CepFailure.notFound);
        expect(cubit.state.addressDraft.isZipCodeUnknown, isTrue);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'does not list cities without a uf',
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.refreshCities(''),
      verify: (_) => verifyNever(() => listCities(uf: any(named: 'uf'))),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'a search is forwarded to the cities list',
      setUp: () {
        when(
          () => listCities(uf: 'DF', search: 'bras'),
        ).thenAnswer((_) async => Ok(fakeIbgeLocationsPage(items: [])));
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.refreshCities('DF', search: 'bras'),
      verify: (_) =>
          verify(() => listCities(uf: 'DF', search: 'bras')).called(1),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'a catalog failure is kept for the UI',
      setUp: () {
        when(
          () => listCities(uf: any(named: 'uf')),
        ).thenAnswer((_) async => const Err(IbgeLocationsFailure.ufNotFound));
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.refreshCities('XX'),
      verify: (cubit) =>
          expect(cubit.state.catalogFailure, IbgeLocationsFailure.ufNotFound),
    );
  });

  group('locks held by a CEP lookup', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'changing the uf is ignored while the city is locked',
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.selectUf('SP'),
      expect: () => <PersonalDataState>[],
      verify: (_) => verifyNever(() => listCities(uf: any(named: 'uf'))),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'choosing a city is ignored while the city is locked',
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) => cubit.selectCity(
        fakeBrazilianCity(token: 'city-sp', name: 'São Paulo', stateUf: 'SP'),
      ),
      expect: () => <PersonalDataState>[],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'the neighborhood cannot be edited when the lookup brought it',
      setUp: () {
        when(
          () => lookupCep(any()),
        ).thenAnswer((_) async => Ok<CepFailure, CepLookup>(fakeCepLookup()));
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) async {
        cubit.updateZipCode('70040010');
        await Future<void>.delayed(cepLookupTestWait);
        cubit.updateNeighborhood('Outro bairro');
      },
      verify: (cubit) {
        expect(cubit.state.addressDraft.neighborhood, 'Taguatinga');
        expect(cubit.state.addressDraft.isNeighborhoodLocked, isTrue);
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'the neighborhood is editable when the lookup did not bring it',
      setUp: () {
        when(() => lookupCep(any())).thenAnswer(
          (_) async =>
              Ok<CepFailure, CepLookup>(fakeCepLookup(neighborhood: null)),
        );
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) async {
        cubit.updateZipCode('70040010');
        await Future<void>.delayed(cepLookupTestWait);
        cubit.updateNeighborhood('Asa Sul');
      },
      verify: (cubit) =>
          expect(cubit.state.addressDraft.neighborhood, 'Asa Sul'),
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'a failed lookup releases the city and the neighborhood again',
      setUp: () {
        when(() => lookupCep(any())).thenAnswer(
          (_) async => const Err<CepFailure, CepLookup>(CepFailure.rateLimited),
        );
      },
      build: buildCubit,
      seed: () => readyState(address: fakePersonalAddress()),
      act: (cubit) async {
        cubit.updateZipCode('70040010');
        await Future<void>.delayed(cepLookupTestWait);
        cubit.updateNeighborhood('Asa Sul');
        await cubit.selectUf('DF');
        cubit.selectCity(fakeBrazilianCity());
      },
      verify: (cubit) {
        expect(cubit.state.addressDraft.neighborhood, 'Asa Sul');
        expect(cubit.state.addressDraft.cityToken, 'city-brasilia');
        expect(cubit.state.addressDraft.uf, 'DF');
      },
    );
  });

  group('requestEmailChange', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'submits email change and syncs pending profile',
      setUp: () {
        when(() => requestEmailChange(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(pendingEmail: 'novo@vanep.com.br'),
          ),
        );
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.requestEmailChange(' novo@vanep.com.br '),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.emailSubmitting,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having(
              (s) => s.profile?.pendingEmail,
              'pendingEmail',
              'novo@vanep.com.br',
            )
            .having(
              (s) => s.feedback,
              'feedback',
              const PersonalDataEmailChangeSuccessFeedback(),
            ),
      ],
      verify: (_) {
        verify(() => requestEmailChange('novo@vanep.com.br')).called(1);
        expect(syncedProfiles.single.pendingEmail, 'novo@vanep.com.br');
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'maps email field errors on failure',
      setUp: () {
        when(() => requestEmailChange(any())).thenAnswer(
          (_) async => const Err<ProfileEditFailure, UserProfile>(
            StructuredProfileEditFailure(
              code: ProfileErrorCode.emailDuplicate,
              field: 'email',
            ),
          ),
        );
      },
      build: buildCubit,
      seed: readyState,
      act: (cubit) => cubit.requestEmailChange('dup@vanep.com.br'),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.emailSubmitting,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.fieldErrors, 'fieldErrors', {
              'email': ProfileErrorCode.emailDuplicate,
            }),
      ],
      verify: (_) => expect(syncedProfiles, isEmpty),
    );
  });

  test('buildProfilePatchFromDrafts includes only changed keys', () {
    final request = buildProfilePatchFromDrafts(
      snapshot: const FakeUserProfile(),
      draftName: 'Ana Motorista',
      draftPhone: '11988887777',
      draftGender: Gender.male,
    );

    expect(request.includesName, isFalse);
    expect(request.includesPhone, isTrue);
    expect(request.phone, '11988887777');
    expect(request.includesGender, isTrue);
    expect(request.gender, Gender.male);
  });
}
