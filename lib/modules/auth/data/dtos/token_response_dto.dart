import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response_dto.freezed.dart';
part 'token_response_dto.g.dart';

/// Response of the `/oauth2/token` endpoint (authorization_code and refresh).
@freezed
abstract class TokenResponseDto with _$TokenResponseDto {
  const factory TokenResponseDto({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresInSeconds,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'scope') String? scope,
  }) = _TokenResponseDto;

  factory TokenResponseDto.fromJson(Map<String, Object?> json) =>
      _$TokenResponseDtoFromJson(json);
}
