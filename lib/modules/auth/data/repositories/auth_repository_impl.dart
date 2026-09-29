import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/profile_patch_request.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/google_id_token_source.dart';
import '../datasources/oauth_remote_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../dtos/auth_session_dto.dart';
import '../dtos/token_response_dto.dart';
import '../dtos/user_profile_dto.dart';
import '../mappers/profile_edit_failure_mapper.dart';
import '../mappers/token_endpoint_failure_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.profileRemote,
    required this.local,
    required this.googleIdTokens,
    DateTime Function() clock = DateTime.now,
  }) : _now = clock;

  final OAuthRemoteDataSource remote;
  final UserProfileRemoteDataSource profileRemote;
  final AuthLocalDataSource local;
  final GoogleIdTokenSource googleIdTokens;
  final DateTime Function() _now;
  Future<Result<AuthFailure, AuthSession?>>? _refreshInFlight;

  @override
  Future<Result<AuthFailure, AuthSession>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final TokenResponseDto token;
    try {
      token = await remote.requestPasswordGrant(
        email: email,
        password: password,
      );
    } on DioException catch (error) {
      return Err(mapTokenEndpointFailure(error));
    }
    return startSessionOrFailure(token);
  }

  @override
  Future<Result<AuthFailure, AuthSession>> signInWithGoogle() async {
    final String? idToken;
    try {
      idToken = await googleIdTokens.requestIdToken();
    } on GoogleIdTokenException catch (error) {
      return Err(GoogleSignInAuthFailure(error.reason));
    }
    if (idToken == null) return const Err(CancelledAuthFailure());

    final TokenResponseDto token;
    try {
      token = await remote.requestGoogleGrant(idToken);
    } on DioException catch (error) {
      return Err(mapTokenEndpointFailure(error));
    }
    return startSessionOrFailure(token);
  }

  Future<Result<AuthFailure, AuthSession>> startSessionOrFailure(
    TokenResponseDto token,
  ) async {
    try {
      return Ok(await startSessionFromToken(token));
    } on DioException catch (error) {
      return Err(NetworkAuthFailure(error.message));
    }
  }

  Future<AuthSessionDto> startSessionFromToken(TokenResponseDto token) async {
    final profile = await remote.fetchProfile(token.accessToken);
    final session = sessionFromTokenResponse(
      token: token,
      profile: profile,
      now: _now(),
    );
    await local.saveSession(session);
    return session;
  }

  @override
  Future<Result<AuthFailure, AuthSession?>> currentSession() async {
    final stored = await local.readSession();
    if (stored == null) return const Ok(null);
    if (!stored.isExpired(_now())) return Ok(stored);
    return refreshSession();
  }

  @override
  Future<Result<AuthFailure, AuthSession?>> refreshSession() {
    return _refreshInFlight ??=
        exchangeStoredRefreshToken(
          remote: remote,
          local: local,
          now: _now,
        ).whenComplete(() => _refreshInFlight = null);
  }

  @override
  Future<Result<AuthFailure, void>> signOut() async {
    final stored = await local.readSession();
    if (stored != null) {
      await revokeQuietly(remote, stored.refreshToken, 'refresh_token');
      await revokeQuietly(remote, stored.accessToken, 'access_token');
    }
    await local.clearSession();
    await googleIdTokens.signOut();
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

Future<Result<AuthFailure, AuthSession?>> exchangeStoredRefreshToken({
  required OAuthRemoteDataSource remote,
  required AuthLocalDataSource local,
  required DateTime Function() now,
}) async {
  final stored = await local.readSession();
  if (stored == null) return const Ok(null);

  try {
    final token = await remote.refresh(stored.refreshToken);
    final refreshed = sessionFromTokenResponse(
      token: token,
      profile: stored.profile,
      now: now(),
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
  if (await local.readSession() == null) {
    return const Err(UnexpectedProfileEditFailure('no_session'));
  }
  try {
    final profile = await loadProfile();
    final current = await local.readSession();
    if (current == null) {
      return const Err(UnexpectedProfileEditFailure('no_session'));
    }
    await local.saveSession(current.copyWith(profile: profile));
    return Ok(profile);
  } on DioException catch (error) {
    return Err(mapProfileEditDioException(error));
  } on Object catch (error) {
    return Err(UnexpectedProfileEditFailure(error.toString()));
  }
}
