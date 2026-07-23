import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/value_objects/user_type.dart';

part 'user_profile_dto.freezed.dart';
part 'user_profile_dto.g.dart';

@freezed
abstract class UserProfileDto with _$UserProfileDto implements UserProfile {
  const factory UserProfileDto({
    required String token,
    String? name,
    String? email,
    @JsonKey(fromJson: UserType.fromApi, toJson: UserType.toApi) UserType? type,
  }) = _UserProfileDto;

  factory UserProfileDto.fromJson(Map<String, Object?> json) =>
      _$UserProfileDtoFromJson(json);
}
