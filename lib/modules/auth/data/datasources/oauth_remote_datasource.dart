import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_profile_dto.dart';

/// Talks to the Spring Authorization Server: token exchange, refresh, profile
/// and revocation. All OAuth requests use the public client id (no secret).
class OAuthRemoteDataSource {
  OAuthRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  static final _formOptions =
      Options(contentType: Headers.formUrlEncodedContentType);

  /// Exchanges an authorization [code] (+ PKCE [codeVerifier]) for tokens.
  Future<TokenResponseDto> exchangeCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.tokenEndpoint,
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': environment.oauthClientId,
        'code_verifier': codeVerifier,
      },
      options: _formOptions,
    );
    return TokenResponseDto.fromJson(response.data!);
  }

  /// Obtains a fresh access/refresh token pair from a [refreshToken].
  Future<TokenResponseDto> refresh(String refreshToken) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.tokenEndpoint,
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': environment.oauthClientId,
      },
      options: _formOptions,
    );
    return TokenResponseDto.fromJson(response.data!);
  }

  /// Fetches the authenticated user's profile with a bearer [accessToken].
  Future<UserProfileDto> fetchProfile(String accessToken) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.userProfileEndpoint,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserProfileDto.fromJson(response.data!);
  }

  /// Best-effort revocation of a token (`token_type_hint` = access/refresh).
  Future<void> revoke(String token, String tokenTypeHint) async {
    await dio.post<void>(
      environment.revocationEndpoint,
      data: {
        'token': token,
        'token_type_hint': tokenTypeHint,
        'client_id': environment.oauthClientId,
      },
      options: _formOptions,
    );
  }
}
