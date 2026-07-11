import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_session.dart';
import 'user_profile_dto.dart';

part 'auth_session_dto.freezed.dart';
part 'auth_session_dto.g.dart';

/// Persisted OAuth session (implements the [AuthSession] entity).
///
/// This is what the local datasource stores in Hive as a JSON string, so it
/// carries [UserProfileDto] and an ISO-8601 [expiresAt].
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
