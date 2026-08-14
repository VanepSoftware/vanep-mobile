import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/usecases/patch_user_profile.dart';
import '../../domain/usecases/refresh_user_profile.dart';
import '../../domain/usecases/request_email_change.dart';
import '../../domain/value_objects/gender.dart';
import '../../domain/value_objects/profile_patch_request.dart';
import '../formatters/profile_field_formatters.dart';
import 'personal_data_state.dart';

typedef SyncProfile = void Function(UserProfile profile);

class PersonalDataCubit extends Cubit<PersonalDataState> {
  PersonalDataCubit({
    required this._refreshUserProfile,
    required this._patchUserProfile,
    required this._requestEmailChange,
    required this._syncProfile,
  }) : super(const PersonalDataState());

  final RefreshUserProfile _refreshUserProfile;
  final PatchUserProfile _patchUserProfile;
  final RequestEmailChange _requestEmailChange;
  final SyncProfile _syncProfile;

  Future<void> load() => refresh();

  Future<void> refresh() async {
    emit(
      state.copyWith(
        status: PersonalDataStatus.loading,
        clearFeedback: true,
      ),
    );
    final result = await _refreshUserProfile();
    result.fold(
      (_) => emit(state.copyWith(status: PersonalDataStatus.loadFailed)),
      applyLoadedProfile,
    );
  }

  void updateName(String value) {
    emit(
      state.copyWith(
        draftName: value,
        fieldErrors: fieldErrorsWithout(state.fieldErrors, 'name'),
      ),
    );
  }

  void updatePhone(String value) {
    emit(
      state.copyWith(
        draftPhone: extractPhoneDigits(value),
        fieldErrors: fieldErrorsWithout(state.fieldErrors, 'phone'),
      ),
    );
  }

  void updateGender(Gender gender) {
    emit(
      state.copyWith(
        draftGender: gender,
        fieldErrors: fieldErrorsWithout(state.fieldErrors, 'gender'),
      ),
    );
  }

  Future<void> save() async {
    final snapshot = state.profile;
    if (snapshot == null || !state.isDirty || state.isSaving) return;

    final request = buildProfilePatchFromDrafts(
      snapshot: snapshot,
      draftName: state.draftName,
      draftPhone: state.draftPhone,
      draftGender: state.draftGender,
    );
    if (request.isEmpty) return;

    emit(
      state.copyWith(
        status: PersonalDataStatus.saving,
        clearFieldErrors: true,
        clearFeedback: true,
      ),
    );

    final result = await _patchUserProfile(request);
    result.fold(applyMutationFailure, (profile) {
      _syncProfile(profile);
      emit(
        stateFromProfile(
          profile,
          status: PersonalDataStatus.ready,
          feedback: const PersonalDataSaveSuccessFeedback(),
        ),
      );
    });
  }

  Future<void> requestEmailChange(String email) async {
    if (state.isEmailSubmitting) return;

    emit(
      state.copyWith(
        status: PersonalDataStatus.emailSubmitting,
        fieldErrors: fieldErrorsWithout(state.fieldErrors, 'email'),
        clearFeedback: true,
      ),
    );

    final result = await _requestEmailChange(email.trim());
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: PersonalDataStatus.ready,
            fieldErrors: fieldErrorsFromFailure(failure, fallbackField: 'email'),
            feedback: PersonalDataFailureFeedback(failure),
          ),
        );
      },
      (profile) {
        _syncProfile(profile);
        emit(
          stateFromProfile(
            profile,
            status: PersonalDataStatus.ready,
            feedback: const PersonalDataEmailChangeSuccessFeedback(),
          ),
        );
      },
    );
  }

  void clearFeedback() {
    if (state.feedback == null) return;
    emit(state.copyWith(clearFeedback: true));
  }

  void applyLoadedProfile(UserProfile profile) {
    emit(stateFromProfile(profile, status: PersonalDataStatus.ready));
  }

  void applyMutationFailure(ProfileEditFailure failure) {
    emit(
      state.copyWith(
        status: PersonalDataStatus.ready,
        fieldErrors: fieldErrorsFromFailure(failure),
        feedback: PersonalDataFailureFeedback(failure),
      ),
    );
  }
}

PersonalDataState stateFromProfile(
  UserProfile profile, {
  required PersonalDataStatus status,
  PersonalDataFeedback? feedback,
}) {
  return PersonalDataState(
    status: status,
    profile: profile,
    draftName: profile.name ?? '',
    draftPhone: profile.phone ?? '',
    draftGender: profile.gender,
    feedback: feedback,
  );
}

ProfilePatchRequest buildProfilePatchFromDrafts({
  required UserProfile snapshot,
  required String draftName,
  required String draftPhone,
  required Gender? draftGender,
}) {
  final builder = ProfilePatchRequestBuilder();
  if (draftName != (snapshot.name ?? '')) {
    builder.setName(draftName);
  }
  if (draftPhone != (snapshot.phone ?? '')) {
    builder.setPhone(draftPhone);
  }
  if (draftGender != snapshot.gender && draftGender != null) {
    builder.setGender(draftGender);
  }
  return builder.build();
}

Map<String, ProfileErrorCode> fieldErrorsWithout(
  Map<String, ProfileErrorCode> current,
  String field,
) {
  if (!current.containsKey(field)) return current;
  return Map<String, ProfileErrorCode>.from(current)..remove(field);
}

Map<String, ProfileErrorCode> fieldErrorsFromFailure(
  ProfileEditFailure failure, {
  String? fallbackField,
}) {
  if (failure is! StructuredProfileEditFailure) return const {};
  final field = failure.field ?? fallbackField;
  if (field == null || field.isEmpty) return const {};
  return {field: failure.code};
}
