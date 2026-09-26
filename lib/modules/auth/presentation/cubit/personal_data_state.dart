import 'package:equatable/equatable.dart';

import '../../../../core/domain/gender.dart';
import '../../../../core/domain/postal_address_draft.dart';
import '../../../ibge_locations/domain/entities/brazilian_city.dart';
import '../../../ibge_locations/domain/entities/brazilian_state.dart';
import '../../../ibge_locations/domain/failures/cep_failure.dart';
import '../../../ibge_locations/domain/failures/ibge_locations_failure.dart';
import '../../domain/entities/personal_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/personal_address_failure.dart';
import '../../domain/failures/profile_edit_failure.dart';

enum PersonalDataStatus {
  initial,
  loading,
  ready,
  saving,
  emailSubmitting,
  loadFailed,
}

sealed class PersonalDataFeedback extends Equatable {
  const PersonalDataFeedback();

  @override
  List<Object?> get props => [];
}

class PersonalDataSaveSuccessFeedback extends PersonalDataFeedback {
  const PersonalDataSaveSuccessFeedback();
}

class PersonalDataEmailChangeSuccessFeedback extends PersonalDataFeedback {
  const PersonalDataEmailChangeSuccessFeedback();
}

class PersonalDataAddressClearedFeedback extends PersonalDataFeedback {
  const PersonalDataAddressClearedFeedback();
}

class PersonalDataFailureFeedback extends PersonalDataFeedback {
  const PersonalDataFailureFeedback(this.failure);

  final ProfileEditFailure failure;

  @override
  List<Object?> get props => [failure];
}

class PersonalDataAddressFailureFeedback extends PersonalDataFeedback {
  const PersonalDataAddressFailureFeedback(this.failure);

  final PersonalAddressFailure failure;

  @override
  List<Object?> get props => [failure];
}

class PersonalDataAddressSaveFailureFeedback extends PersonalDataFeedback {
  const PersonalDataAddressSaveFailureFeedback(this.failure);

  final PersonalAddressFailure failure;

  @override
  List<Object?> get props => [failure];
}

class PersonalDataState extends Equatable {
  const PersonalDataState({
    this.status = PersonalDataStatus.initial,
    this.profile,
    this.draftName = '',
    this.draftPhone = '',
    this.draftGender,
    this.address,
    this.addressDraft = const PostalAddressDraft(),
    this.cepFailure,
    this.isLookingUpCep = false,
    this.catalogStates = const [],
    this.catalogCities = const [],
    this.catalogFailure,
    this.fieldErrors = const {},
    this.feedback,
  });

  final PersonalDataStatus status;
  final UserProfile? profile;
  final String draftName;
  final String draftPhone;
  final Gender? draftGender;
  final PersonalAddress? address;
  final PostalAddressDraft addressDraft;
  final CepFailure? cepFailure;
  final bool isLookingUpCep;
  final List<BrazilianState> catalogStates;
  final List<BrazilianCity> catalogCities;
  final IbgeLocationsFailure? catalogFailure;
  final Map<String, ProfileErrorCode> fieldErrors;
  final PersonalDataFeedback? feedback;

  bool get isProfileDirty {
    final snapshot = profile;
    if (snapshot == null) return false;
    return draftName != (snapshot.name ?? '') ||
        draftPhone != (snapshot.phone ?? '') ||
        draftGender != snapshot.gender;
  }

  bool get isAddressDirty {
    final saved = address?.toDraft() ?? const PostalAddressDraft();
    return !addressDraft.sameContentAs(saved);
  }

  bool get isAddressSavable => isAddressDirty && addressDraft.isSavable;

  bool get canSave =>
      status == PersonalDataStatus.ready &&
      profile != null &&
      (isProfileDirty || isAddressSavable);

  bool get isSaving => status == PersonalDataStatus.saving;

  bool get isEmailSubmitting => status == PersonalDataStatus.emailSubmitting;

  PersonalDataState copyWith({
    PersonalDataStatus? status,
    UserProfile? profile,
    String? draftName,
    String? draftPhone,
    Gender? draftGender,
    bool clearDraftGender = false,
    PersonalAddress? address,
    bool clearAddress = false,
    PostalAddressDraft? addressDraft,
    CepFailure? cepFailure,
    bool clearCepFailure = false,
    bool? isLookingUpCep,
    List<BrazilianState>? catalogStates,
    List<BrazilianCity>? catalogCities,
    IbgeLocationsFailure? catalogFailure,
    bool clearCatalogFailure = false,
    Map<String, ProfileErrorCode>? fieldErrors,
    PersonalDataFeedback? feedback,
    bool clearFeedback = false,
    bool clearFieldErrors = false,
  }) {
    return PersonalDataState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      draftName: draftName ?? this.draftName,
      draftPhone: draftPhone ?? this.draftPhone,
      draftGender: clearDraftGender ? null : (draftGender ?? this.draftGender),
      address: clearAddress ? null : (address ?? this.address),
      addressDraft: addressDraft ?? this.addressDraft,
      cepFailure: clearCepFailure ? null : (cepFailure ?? this.cepFailure),
      isLookingUpCep: isLookingUpCep ?? this.isLookingUpCep,
      catalogStates: catalogStates ?? this.catalogStates,
      catalogCities: catalogCities ?? this.catalogCities,
      catalogFailure: clearCatalogFailure
          ? null
          : (catalogFailure ?? this.catalogFailure),
      fieldErrors: clearFieldErrors
          ? const {}
          : (fieldErrors ?? this.fieldErrors),
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    draftName,
    draftPhone,
    draftGender,
    address,
    addressDraft,
    cepFailure,
    isLookingUpCep,
    catalogStates,
    catalogCities,
    catalogFailure,
    fieldErrors,
    feedback,
  ];
}
