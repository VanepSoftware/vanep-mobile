import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/value_objects/gender.dart';

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

class PersonalDataFailureFeedback extends PersonalDataFeedback {
  const PersonalDataFailureFeedback(this.failure);

  final ProfileEditFailure failure;

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
    this.fieldErrors = const {},
    this.loadFailure,
    this.feedback,
  });

  final PersonalDataStatus status;
  final UserProfile? profile;
  final String draftName;
  final String draftPhone;
  final Gender? draftGender;
  final Map<String, ProfileErrorCode> fieldErrors;
  final ProfileEditFailure? loadFailure;
  final PersonalDataFeedback? feedback;

  bool get isDirty {
    final snapshot = profile;
    if (snapshot == null) return false;
    return draftName != (snapshot.name ?? '') ||
        draftPhone != (snapshot.phone ?? '') ||
        draftGender != snapshot.gender;
  }

  bool get canSave =>
      isDirty &&
      status == PersonalDataStatus.ready &&
      profile != null;

  bool get isSaving => status == PersonalDataStatus.saving;

  bool get isEmailSubmitting => status == PersonalDataStatus.emailSubmitting;

  PersonalDataState copyWith({
    PersonalDataStatus? status,
    UserProfile? profile,
    String? draftName,
    String? draftPhone,
    Gender? draftGender,
    Map<String, ProfileErrorCode>? fieldErrors,
    ProfileEditFailure? loadFailure,
    PersonalDataFeedback? feedback,
    bool clearLoadFailure = false,
    bool clearFeedback = false,
    bool clearFieldErrors = false,
  }) {
    return PersonalDataState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      draftName: draftName ?? this.draftName,
      draftPhone: draftPhone ?? this.draftPhone,
      draftGender: draftGender ?? this.draftGender,
      fieldErrors: clearFieldErrors
          ? const {}
          : (fieldErrors ?? this.fieldErrors),
      loadFailure: clearLoadFailure ? null : (loadFailure ?? this.loadFailure),
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
    fieldErrors,
    loadFailure,
    feedback,
  ];
}
