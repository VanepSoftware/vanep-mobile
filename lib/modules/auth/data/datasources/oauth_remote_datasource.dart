import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_profile_dto.dart';

class OAuthRemoteDataSource {
  OAuthRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  static const String passwordGrantType =
      'urn:vanep:params:oauth:grant-type:password';

  static final _formOptions = Options(
    contentType: Headers.formUrlEncodedContentType,
  );

  Future<TokenResponseDto> requestPasswordGrant({
    required String email,
    required String password,
  }) {
    return requestToken({
      'grant_type': passwordGrantType,
      'username': email,
      'password': password,
    });
  }

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

  Future<TokenResponseDto> refresh(String refreshToken) {
    return requestToken({
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
  }

  Future<TokenResponseDto> requestToken(Map<String, String> grant) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.tokenEndpoint,
      data: {...grant, 'client_id': environment.oauthClientId},
      options: _formOptions,
    );
    return TokenResponseDto.fromJson(response.data!);
  }

  Future<UserProfileDto> fetchProfile(String accessToken) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.userProfileEndpoint,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserProfileDto.fromJson(response.data!);
  }

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
