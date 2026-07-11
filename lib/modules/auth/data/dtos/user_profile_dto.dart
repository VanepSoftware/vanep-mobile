import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

/// Response of `/api/user/profile`; implements the [UserProfile] entity.
@freezed
abstract class UserProfileDto with _$UserProfileDto implements UserProfile {
  const factory UserProfileDto({
    required String token,
    String? name,
    String? email,
    String? type,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, Object?> json) =>
      _$UserProfileDtoFromJson(json);
}
