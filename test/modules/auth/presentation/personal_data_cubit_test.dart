import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/personal_data_state.dart';

import '../auth_fixtures.dart';
import '../auth_mocks.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockRefreshUserProfile refreshUserProfile;
  late MockPatchUserProfile patchUserProfile;
  late MockRequestEmailChange requestEmailChange;
  late List<UserProfile> syncedProfiles;

  setUpAll(registerAuthFallbacks);

  setUp(() {
    refreshUserProfile = MockRefreshUserProfile();
    patchUserProfile = MockPatchUserProfile();
    requestEmailChange = MockRequestEmailChange();
    syncedProfiles = [];
  });

  PersonalDataCubit buildCubit() => PersonalDataCubit(
    refreshUserProfile: refreshUserProfile,
    patchUserProfile: patchUserProfile,
    requestEmailChange: requestEmailChange,
    syncProfile: syncedProfiles.add,
  );

  group('load', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'emits loading then ready with drafts from profile',
      setUp: () => when(refreshUserProfile.call).thenAnswer(
        (_) async =>
            const Ok<ProfileEditFailure, UserProfile>(FakeUserProfile()),
      ),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PersonalDataState(status: PersonalDataStatus.loading),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having((s) => s.draftName, 'draftName', 'Ana Motorista')
            .having((s) => s.draftPhone, 'draftPhone', '11999999999')
            .having((s) => s.draftGender, 'draftGender', Gender.female)
            .having((s) => s.isDirty, 'isDirty', false),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'emits loadFailed on refresh error',
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
  });

  group('drafts and save', () {
    blocTest<PersonalDataCubit, PersonalDataState>(
      'updatePhone stores only digits from a masked value',
      build: buildCubit,
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ),
      act: (cubit) => cubit.updatePhone('(11) 98888-7777'),
      expect: () => [
        isA<PersonalDataState>()
            .having((s) => s.draftPhone, 'draftPhone', '11988887777')
            .having((s) => s.isDirty, 'isDirty', true),
      ],
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'updateName marks dirty and clears name field error',
      build: buildCubit,
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ).copyWith(
        fieldErrors: const { 'name': ProfileErrorCode.fieldNull },
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
      'save patches only changed fields and syncs profile',
      setUp: () {
        when(() => patchUserProfile(any())).thenAnswer(
          (_) async => const Ok<ProfileEditFailure, UserProfile>(
            FakeUserProfile(name: 'Maria'),
          ),
        );
      },
      build: buildCubit,
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ).copyWith(draftName: 'Maria'),
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
        final captured = verify(
          () => patchUserProfile(captureAny()),
        ).captured.single as ProfilePatchRequest;
        expect(captured.includesName, isTrue);
        expect(captured.name, 'Maria');
        expect(captured.includesPhone, isFalse);
        expect(captured.includesGender, isFalse);
        expect(syncedProfiles, hasLength(1));
        expect(syncedProfiles.single.name, 'Maria');
      },
    );

    blocTest<PersonalDataCubit, PersonalDataState>(
      'save does nothing when not dirty',
      build: buildCubit,
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ),
      act: (cubit) => cubit.save(),
      expect: () => <PersonalDataState>[],
      verify: (_) => verifyNever(() => patchUserProfile(any())),
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
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ).copyWith(draftPhone: ''),
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.saving,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having(
              (s) => s.fieldErrors,
              'fieldErrors',
              { 'phone': ProfileErrorCode.phoneBlank },
            )
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
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ),
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
      seed: () => stateFromProfile(
        const FakeUserProfile(),
        status: PersonalDataStatus.ready,
      ),
      act: (cubit) => cubit.requestEmailChange('dup@vanep.com.br'),
      expect: () => [
        isA<PersonalDataState>().having(
          (s) => s.status,
          'status',
          PersonalDataStatus.emailSubmitting,
        ),
        isA<PersonalDataState>()
            .having((s) => s.status, 'status', PersonalDataStatus.ready)
            .having(
              (s) => s.fieldErrors,
              'fieldErrors',
              { 'email': ProfileErrorCode.emailDuplicate },
            ),
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
