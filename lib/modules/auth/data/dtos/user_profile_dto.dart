import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/value_objects/gender.dart';
import '../../domain/value_objects/onboarding_step.dart';
import '../../domain/value_objects/user_type.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
abstract class UserProfileDto with _$UserProfileDto implements UserProfile {
  const factory UserProfileDto({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? document,
    String? birthDate,
    @JsonKey(fromJson: Gender.fromApi, toJson: Gender.toApi) Gender? gender,
    @JsonKey(fromJson: UserType.fromApi, toJson: UserType.toApi) UserType? type,
    String? pendingEmail,
    DateTime? nameChangeAvailableAt,
    DateTime? phoneChangeAvailableAt,
    DateTime? emailChangeAvailableAt,
    @JsonKey(
      name: 'onboarding',
      fromJson: OnboardingStep.listFromApi,
      includeToJson: false,
    )
    @Default(<OnboardingStep>[])
    List<OnboardingStep> pendingOnboardingSteps,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, Object?> json) =>
      _$UserProfileDtoFromJson(json);
}
