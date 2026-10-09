import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';

part 'auth_session_dto.freezed.dart';
part 'auth_session_dto.g.dart';

@freezed
abstract class AuthSessionDto with _$AuthSessionDto implements AuthSession {
  const factory AuthSessionDto({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required UserProfileDto profile,
  }) = _AuthSessionDto;

  factory AuthSessionDto.fromJson(Map<String, Object?> json) =>
      _$AuthSessionDtoFromJson(json);
}
