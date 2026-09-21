import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../../../../core/result/result.dart';
import '../../../ibge_locations/domain/entities/brazilian_city.dart';
import '../../../ibge_locations/domain/entities/cep_lookup.dart';
import '../../../ibge_locations/domain/failures/cep_failure.dart';
import '../../../ibge_locations/domain/usecases/list_cities.dart';
import '../../../ibge_locations/domain/usecases/list_states.dart';
import '../../../ibge_locations/domain/usecases/lookup_cep.dart';
import '../../domain/entities/personal_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/personal_address_failure.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/usecases/delete_my_personal_address.dart';
import '../../domain/usecases/find_my_personal_address.dart';
import '../../domain/usecases/patch_user_profile.dart';
import '../../domain/usecases/refresh_user_profile.dart';
import '../../domain/usecases/request_email_change.dart';
import '../../domain/usecases/upsert_my_personal_address.dart';
import '../../domain/value_objects/personal_address_write.dart';
import '../../domain/value_objects/profile_patch_request.dart';
import '../formatters/profile_field_formatters.dart';
import 'personal_data_state.dart';

typedef SyncProfile = void Function(UserProfile profile);

const personalAddressCepLookupDebounce = Duration(milliseconds: 400);

class PersonalDataCubit extends Cubit<PersonalDataState> {
  PersonalDataCubit({
    required this._refreshUserProfile,
    required this._patchUserProfile,
    required this._requestEmailChange,
    required this._findMyPersonalAddress,
    required this._upsertMyPersonalAddress,
    required this._deleteMyPersonalAddress,
    required this._lookupCep,
    required this._listStates,
    required this._listCities,
    required this._syncProfile,
    this.cepLookupDebounce = personalAddressCepLookupDebounce,
  }) : super(const PersonalDataState());

  final RefreshUserProfile _refreshUserProfile;
  final PatchUserProfile _patchUserProfile;
  final RequestEmailChange _requestEmailChange;
  final FindMyPersonalAddress _findMyPersonalAddress;
  final UpsertMyPersonalAddress _upsertMyPersonalAddress;
  final DeleteMyPersonalAddress _deleteMyPersonalAddress;
  final LookupCep _lookupCep;
  final ListStates _listStates;
  final ListCities _listCities;
  final SyncProfile _syncProfile;
  final Duration cepLookupDebounce;

  Timer? _cepLookupTimer;
  int _cepLookupGeneration = 0;

  Future<void> load() => refresh();

  Future<void> refresh() async {
    emit(
      state.copyWith(status: PersonalDataStatus.loading, clearFeedback: true),
    );
    final profileFuture = _refreshUserProfile();
    final addressFuture = _findMyPersonalAddress();
    final profileResult = await profileFuture;
    final addressResult = await addressFuture;

    switch ((profileResult, addressResult)) {
      case (
        Ok<ProfileEditFailure, UserProfile>(value: final profile),
        Ok<PersonalAddressFailure, PersonalAddress?>(value: final address),
      ):
        emit(
          stateFromProfile(
            profile,
            status: PersonalDataStatus.ready,
            address: address,
          ),
        );
      default:
        emit(state.copyWith(status: PersonalDataStatus.loadFailed));
    }
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

  void updateGender(Gender? gender) {
    emit(
      state.copyWith(
        draftGender: gender,
        clearDraftGender: gender == null,
        fieldErrors: fieldErrorsWithout(state.fieldErrors, 'gender'),
      ),
    );
  }

  void updateZipCode(String value) {
    _cepLookupTimer?.cancel();
    _cepLookupGeneration++;
    final draft = state.addressDraft.withZipCode(value);
    emit(state.copyWith(addressDraft: draft, clearCepFailure: true));
    if (draft.zipCode.length != brazilianZipDigitCount) return;
    final generation = _cepLookupGeneration;
    _cepLookupTimer = Timer(cepLookupDebounce, () {
      if (isClosed || generation != _cepLookupGeneration) return;
      lookupDraftCep();
    });
  }

  void updateStreet(String value) {
    emit(state.copyWith(addressDraft: state.addressDraft.withStreet(value)));
  }

  void updateNeighborhood(String value) {
    if (state.addressDraft.isNeighborhoodLocked) return;
    emit(
      state.copyWith(addressDraft: state.addressDraft.withNeighborhood(value)),
    );
  }

  void updateNumber(String value) {
    emit(state.copyWith(addressDraft: state.addressDraft.withNumber(value)));
  }

  void updateComplement(String value) {
    emit(
      state.copyWith(addressDraft: state.addressDraft.withComplement(value)),
    );
  }

  Future<void> lookupDraftCep() async {
    final cep = state.addressDraft.zipCode;
    if (cep.length != brazilianZipDigitCount) return;
    final generation = _cepLookupGeneration;
    final result = await _lookupCep(cep);
    if (isClosed || generation != _cepLookupGeneration) return;
    switch (result) {
      case Ok<CepFailure, CepLookup>(value: final lookup):
        emit(
          state.copyWith(
            addressDraft: state.addressDraft.withCepLookup(
              cityToken: lookup.cityToken,
              cityName: lookup.cityName,
              uf: lookup.uf,
              street: lookup.street,
              neighborhood: lookup.neighborhood,
            ),
            clearCepFailure: true,
          ),
        );
      case Err<CepFailure, CepLookup>(error: final failure):
        await applyCepLookupFailure(failure);
    }
  }

  Future<void> applyCepLookupFailure(CepFailure failure) async {
    if (failure == CepFailure.invalidFormat) {
      emit(state.copyWith(cepFailure: failure));
      return;
    }
    final draft = failure == CepFailure.notFound
        ? state.addressDraft.withCepUnknown()
        : state.addressDraft.withCepUnavailable();
    emit(state.copyWith(addressDraft: draft, cepFailure: failure));
    await refreshStates();
  }

  Future<void> openCityPicker() async {
    if (state.addressDraft.isCityLocked) return;
    emit(state.copyWith(addressDraft: state.addressDraft.unlockCity()));
    await refreshStates();
  }

  Future<void> refreshStates() async {
    final result = await _listStates();
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(catalogStates: value.items, clearCatalogFailure: true),
        );
      case Err(:final error):
        emit(state.copyWith(catalogFailure: error));
    }
  }

  Future<void> selectUf(String uf) async {
    if (state.addressDraft.isCityLocked) return;
    emit(
      state.copyWith(
        addressDraft: state.addressDraft.withUf(uf),
        catalogCities: const [],
        clearCepFailure: state.cepFailure != CepFailure.notFound,
        clearCatalogFailure: true,
      ),
    );
    await refreshCities(uf);
  }

  Future<void> refreshCities(String uf, {String? search}) async {
    if (uf.isEmpty) return;
    final result = search == null || search.isEmpty
        ? await _listCities(uf: uf)
        : await _listCities(uf: uf, search: search);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(catalogCities: value.items, clearCatalogFailure: true),
        );
      case Err(:final error):
        emit(state.copyWith(catalogFailure: error));
    }
  }

  void selectCity(BrazilianCity city) {
    if (state.addressDraft.isCityLocked) return;
    emit(
      state.copyWith(
        addressDraft: state.addressDraft.withCity(
          token: city.token,
          name: city.name,
          uf: city.stateUf,
        ),
        clearCepFailure: state.cepFailure != CepFailure.notFound,
      ),
    );
  }

  Future<void> save() async {
    if (state.isSaving || !state.canSave) return;
    final snapshot = state.profile;
    if (snapshot == null) return;

    final write = state.isAddressSavable
        ? personalAddressWriteFromDraft(state.addressDraft)
        : null;
    if (!state.isProfileDirty && write == null) return;

    emit(
      state.copyWith(
        status: PersonalDataStatus.saving,
        clearFieldErrors: true,
        clearFeedback: true,
      ),
    );

    var profile = snapshot;
    if (state.isProfileDirty) {
      final request = buildProfilePatchFromDrafts(
        snapshot: snapshot,
        draftName: state.draftName,
        draftPhone: state.draftPhone,
        draftGender: state.draftGender,
      );
      if (!request.isEmpty) {
        final result = await _patchUserProfile(request);
        switch (result) {
          case Err<ProfileEditFailure, UserProfile>(error: final failure):
            applyMutationFailure(failure);
            return;
          case Ok<ProfileEditFailure, UserProfile>(value: final patched):
            profile = patched;
            _syncProfile(patched);
        }
      }
    }

    if (write != null) {
      final result = await _upsertMyPersonalAddress(write);
      switch (result) {
        case Err<PersonalAddressFailure, PersonalAddress>(error: final failure):
          emit(
            stateWithSyncedProfile(
              state,
              profile,
              status: PersonalDataStatus.ready,
              feedback: PersonalDataAddressSaveFailureFeedback(failure),
            ),
          );
          return;
        case Ok<PersonalAddressFailure, PersonalAddress>(
          value: final savedAddress,
        ):
          final refreshed = await _refreshUserProfile();
          switch (refreshed) {
            case Ok<ProfileEditFailure, UserProfile>(value: final latest):
              profile = latest;
              _syncProfile(latest);
            case Err<ProfileEditFailure, UserProfile>():
              break;
          }
          emit(
            stateFromProfile(
              profile,
              status: PersonalDataStatus.ready,
              address: savedAddress,
              feedback: const PersonalDataSaveSuccessFeedback(),
            ),
          );
          return;
      }
    }

    emit(
      stateWithSyncedProfile(
        state,
        profile,
        status: PersonalDataStatus.ready,
        feedback: const PersonalDataSaveSuccessFeedback(),
      ),
    );
  }

  Future<void> clearAddress() async {
    if (state.isSaving) return;

    emit(
      state.copyWith(status: PersonalDataStatus.saving, clearFeedback: true),
    );

    final result = await _deleteMyPersonalAddress();
    switch (result) {
      case Err<PersonalAddressFailure, void>(error: final failure):
        emit(
          state.copyWith(
            status: PersonalDataStatus.ready,
            feedback: PersonalDataAddressFailureFeedback(failure),
          ),
        );
      case Ok<PersonalAddressFailure, void>():
        final refreshed = await _refreshUserProfile();
        switch (refreshed) {
          case Ok<ProfileEditFailure, UserProfile>(value: final latest):
            _syncProfile(latest);
            emit(
              state.copyWith(
                profile: latest,
                status: PersonalDataStatus.ready,
                clearAddress: true,
                addressDraft: const PostalAddressDraft(),
                clearCepFailure: true,
                feedback: const PersonalDataAddressClearedFeedback(),
              ),
            );
          case Err<ProfileEditFailure, UserProfile>():
            emit(
              state.copyWith(
                status: PersonalDataStatus.ready,
                clearAddress: true,
                addressDraft: const PostalAddressDraft(),
                clearCepFailure: true,
                feedback: const PersonalDataAddressClearedFeedback(),
              ),
            );
        }
    }
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
            fieldErrors: fieldErrorsFromFailure(
              failure,
              fallbackField: 'email',
            ),
            feedback: PersonalDataFailureFeedback(failure),
          ),
        );
      },
      (profile) {
        _syncProfile(profile);
        emit(
          stateWithSyncedProfile(
            state,
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

  void applyMutationFailure(ProfileEditFailure failure) {
    emit(
      state.copyWith(
        status: PersonalDataStatus.ready,
        fieldErrors: fieldErrorsFromFailure(failure),
        feedback: PersonalDataFailureFeedback(failure),
      ),
    );
  }

  @override
  Future<void> close() {
    _cepLookupTimer?.cancel();
    return super.close();
  }
}

PersonalDataState stateFromProfile(
  UserProfile profile, {
  required PersonalDataStatus status,
  PersonalDataFeedback? feedback,
  PersonalAddress? address,
}) {
  return PersonalDataState(
    status: status,
    profile: profile,
    draftName: profile.name ?? '',
    draftPhone: profile.phone ?? '',
    draftGender: profile.gender,
    address: address,
    addressDraft: address?.toDraft() ?? const PostalAddressDraft(),
    feedback: feedback,
  );
}

PersonalDataState stateWithSyncedProfile(
  PersonalDataState current,
  UserProfile profile, {
  required PersonalDataStatus status,
  PersonalDataFeedback? feedback,
}) {
  return current.copyWith(
    status: status,
    profile: profile,
    draftName: profile.name ?? '',
    draftPhone: profile.phone ?? '',
    draftGender: profile.gender,
    clearDraftGender: profile.gender == null,
    feedback: feedback,
    clearFieldErrors: true,
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
  if (draftGender != snapshot.gender) {
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
