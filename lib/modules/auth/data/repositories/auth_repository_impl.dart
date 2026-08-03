import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/authorization_request.dart';
import '../../domain/value_objects/profile_patch_request.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/oauth_remote_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../datasources/web_session_cleaner.dart';
import '../dtos/auth_session_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_profile_dto.dart';
import '../mappers/profile_edit_failure_mapper.dart';
import '../pkce/pkce_generator.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.profileRemote,
    required this.local,
    required this.pkce,
    required this.environment,
    required this.webSession,
    DateTime Function() clock = DateTime.now,
  }) : _now = clock;

  final OAuthRemoteDataSource remote;
  final UserProfileRemoteDataSource profileRemote;
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
      final session = sessionFromTokenResponse(
        token: token,
        profile: profile,
        now: _now(),
      );
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
      final refreshed = sessionFromTokenResponse(
        token: token,
        profile: stored.profile,
        now: _now(),
        fallbackRefreshToken: stored.refreshToken,
      );
      await local.saveSession(refreshed);
      return Ok(refreshed);
    } on DioException catch (error) {
      if (isDefinitiveAuthRejection(error)) {
        await local.clearSession();
        return const Ok(null);
      }
      return Ok(stored);
    }
  }

  @override
  Future<Result<AuthFailure, void>> signOut() async {
    final stored = local.readSession();
    if (stored != null) {
      await revokeQuietly(remote, stored.refreshToken, 'refresh_token');
      await revokeQuietly(remote, stored.accessToken, 'access_token');
    }
    await local.clearSession();

    await webSession.clear();
    return const Ok(null);
  }

  @override
  Future<Result<ProfileEditFailure, UserProfile>> refreshUserProfile() {
    return replaceStoredUserProfile(
      local: local,
      loadProfile: profileRemote.fetchMe,
    );
  }

  @override
  Future<Result<ProfileEditFailure, UserProfile>> patchUserProfile(
    ProfilePatchRequest request,
  ) {
    return replaceStoredUserProfile(
      local: local,
      loadProfile: () => profileRemote.patchMe(request.toJsonMap()),
    );
  }

  @override
  Future<Result<ProfileEditFailure, UserProfile>> requestEmailChange(
    String email,
  ) {
    return replaceStoredUserProfile(
      local: local,
      loadProfile: () async {
        await profileRemote.requestEmailChange(email);
        return profileRemote.fetchMe();
      },
    );
  }
}

bool isDefinitiveAuthRejection(DioException error) {
  final status = error.response?.statusCode;
  return status == 400 || status == 401;
}

AuthSessionDto sessionFromTokenResponse({
  required TokenResponseDto token,
  required UserProfileDto profile,
  required DateTime now,
  String? fallbackRefreshToken,
}) {
  return AuthSessionDto(
    accessToken: token.accessToken,
    refreshToken: token.refreshToken ?? fallbackRefreshToken ?? '',
    expiresAt: now.add(Duration(seconds: token.expiresInSeconds)),
    profile: profile,
  );
}

Future<void> revokeQuietly(
  OAuthRemoteDataSource remote,
  String token,
  String hint,
) async {
  if (token.isEmpty) return;
  await remote
      .revoke(token, hint)
      .catchError((Object _) {}, test: (e) => e is DioException);
}

Future<Result<ProfileEditFailure, UserProfile>> replaceStoredUserProfile({
  required AuthLocalDataSource local,
  required Future<UserProfileDto> Function() loadProfile,
}) async {
  final stored = local.readSession();
  if (stored == null) {
    return const Err(UnexpectedProfileEditFailure('no_session'));
  }
  try {
    final profile = await loadProfile();
    await local.saveSession(stored.copyWith(profile: profile));
    return Ok(profile);
  } on DioException catch (error) {
    return Err(mapProfileEditDioException(error));
  } on Object catch (error) {
    return Err(UnexpectedProfileEditFailure(error.toString()));
  }
}
