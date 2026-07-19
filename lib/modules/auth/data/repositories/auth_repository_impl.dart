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

    try {
      final token = await remote.refresh(stored.refreshToken);
      final refreshed = _sessionFrom(
        token,
        stored.profile,
        fallbackRefreshToken: stored.refreshToken,
      );
      await local.saveSession(refreshed);
      return Ok(refreshed);
    } on DioException catch (error) {
      if (_isDefinitiveAuthRejection(error)) {
        // The refresh token is invalid/expired/revoked: the session is dead.
        await local.clearSession();
        return const Ok(null);
      }
      // Transient failure (offline, timeout, 5xx, server restarting): keep the
      // stored session so the user isn't logged out. The token endpoint will be
      // retried on the next request/app start.
      return Ok(stored);
    }
  }

  /// Whether the token endpoint definitively rejected the refresh token.
  ///
  /// OAuth 2.0 returns HTTP 400 `invalid_grant` for an invalid/expired/revoked
  /// refresh token and 401 for client-auth problems. Anything else (no
  /// response, timeout, 5xx) is treated as transient so we don't log the user
  /// out over a flaky network or a backend restart.
  bool _isDefinitiveAuthRejection(DioException error) {
    final status = error.response?.statusCode;
    return status == 400 || status == 401;
  }

  @override
  Future<Result<AuthFailure, void>> signOut() async {
    final stored = local.readSession();
    if (stored != null) {
      await _revokeQuietly(stored.refreshToken, 'refresh_token');
      await _revokeQuietly(stored.accessToken, 'access_token');
    }
    await local.clearSession();

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
    await remote
        .revoke(token, hint)
        .catchError((Object _) {}, test: (e) => e is DioException);
  }
}
