import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/authorization_request.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/oauth_remote_datasource.dart';
import '../datasources/web_session_cleaner.dart';
import '../dtos/auth_session_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_profile_dto.dart';
import '../pkce/pkce_generator.dart';

/// Data-layer implementation of [AuthRepository]: composes PKCE generation,
/// the OAuth remote calls and local session persistence.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.pkce,
    required this.environment,
    required this.webSession,
    DateTime Function() clock = DateTime.now,
  }) : _now = clock;

  final OAuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  final PkceGenerator pkce;
  final Environment environment;
  final WebSessionCleaner webSession;
  final DateTime Function() _now;

  @override
  AuthorizationRequest buildAuthorizationRequest() {
    final verifier = pkce.createCodeVerifier();
    final challenge = pkce.createCodeChallenge(verifier);
    final state = pkce.createState();

    final url = Uri.parse(environment.authorizationEndpoint).replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': environment.oauthClientId,
        'redirect_uri': environment.oauthRedirectUri,
        'scope': environment.oauthScopes,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'state': state,
      },
    );

    return AuthorizationRequest(
      authorizationUrl: url.toString(),
      redirectUri: environment.oauthRedirectUri,
      state: state,
      codeVerifier: verifier,
    );
  }

  @override
  Future<Result<AuthFailure, AuthSession>> exchangeCode({
    required String code,
    required AuthorizationRequest request,
  }) async {
    try {
      final token = await remote.exchangeCode(
        code: code,
        codeVerifier: request.codeVerifier,
        redirectUri: request.redirectUri,
      );
      final profile = await remote.fetchProfile(token.accessToken);
      final session = _sessionFrom(token, profile);
      await local.saveSession(session);
      return Ok(session);
    } on DioException catch (error) {
      return Err(NetworkAuthFailure(error.message));
    } on Object catch (error) {
      return Err(UnexpectedAuthFailure(error.toString()));
    }
  }

  @override
  Future<Result<AuthFailure, AuthSession?>> currentSession() async {
    final stored = local.readSession();
    if (stored == null) return const Ok(null);
    if (!stored.isExpired(_now())) return Ok(stored);

    // Access token expired: try a silent refresh; on failure, sign the user out.
    try {
      final token = await remote.refresh(stored.refreshToken);
      final refreshed = _sessionFrom(token, stored.profile,
          fallbackRefreshToken: stored.refreshToken);
      await local.saveSession(refreshed);
      return Ok(refreshed);
    } on DioException {
      await local.clearSession();
      return const Ok(null);
    }
  }

  @override
  Future<Result<AuthFailure, void>> signOut() async {
    final stored = local.readSession();
    if (stored != null) {
      await _revokeQuietly(stored.refreshToken, 'refresh_token');
      await _revokeQuietly(stored.accessToken, 'access_token');
    }
    await local.clearSession();
    // Wipe the WebView session cookie so the next login shows the login page
    // instead of silently reusing the still-authenticated server session.
    await webSession.clear();
    return const Ok(null);
  }

  AuthSessionDto _sessionFrom(
    TokenResponseDto token,
    UserProfileDto profile, {
    String? fallbackRefreshToken,
  }) {
    return AuthSessionDto(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken ?? fallbackRefreshToken ?? '',
      expiresAt: _now().add(Duration(seconds: token.expiresInSeconds)),
      profile: profile,
    );
  }

  Future<void> _revokeQuietly(String token, String hint) async {
    if (token.isEmpty) return;
    try {
      await remote.revoke(token, hint);
    } on DioException {
      // Best-effort: local sign-out proceeds even if revocation fails.
    }
  }
}
