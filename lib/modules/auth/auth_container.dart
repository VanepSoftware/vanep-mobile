import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/environment/environment.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../../core/result/result.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/oauth_remote_datasource.dart';
import 'data/datasources/user_profile_remote_datasource.dart';
import 'data/datasources/web_session_cleaner.dart';
import 'data/pkce/pkce_generator.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/build_authorization_request.dart';
import 'domain/usecases/exchange_authorization_code.dart';
import 'domain/usecases/get_current_session.dart';
import 'domain/usecases/patch_user_profile.dart';
import 'domain/usecases/refresh_user_profile.dart';
import 'domain/usecases/request_email_change.dart';
import 'domain/usecases/sign_out.dart';
import 'presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/personal_data_cubit.dart';

void registerAuthDependencies(GetIt getIt, {required Box<String> authBox}) {
  final environment = getIt<Environment>();
  final oauthDio = DioClient.create(environment.authBaseUrl);

  getIt
    ..registerSingleton<OAuthRemoteDataSource>(
      OAuthRemoteDataSource(dio: oauthDio, environment: environment),
    )
    ..registerSingleton<AuthLocalDataSource>(AuthLocalDataSource(authBox))
    ..registerSingleton<PkceGenerator>(PkceGenerator())
    ..registerSingleton<WebSessionCleaner>(
      WebViewWebSessionCleaner(WebViewCookieManager()),
    );

  getIt.registerSingleton<Dio>(
    _buildAuthenticatedDio(getIt, environment),
    instanceName: authenticatedDioName,
  );

  getIt
    ..registerSingleton<UserProfileRemoteDataSource>(
      UserProfileRemoteDataSource(
        dio: getIt<Dio>(instanceName: authenticatedDioName),
        environment: environment,
      ),
    )
    ..registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        remote: getIt<OAuthRemoteDataSource>(),
        profileRemote: getIt<UserProfileRemoteDataSource>(),
        local: getIt<AuthLocalDataSource>(),
        pkce: getIt<PkceGenerator>(),
        environment: environment,
        webSession: getIt<WebSessionCleaner>(),
      ),
    )
    ..registerFactory<GetCurrentSession>(
      () => GetCurrentSession(getIt<AuthRepository>()),
    )
    ..registerFactory<BuildAuthorizationRequest>(
      () => BuildAuthorizationRequest(getIt<AuthRepository>()),
    )
    ..registerFactory<ExchangeAuthorizationCode>(
      () => ExchangeAuthorizationCode(getIt<AuthRepository>()),
    )
    ..registerFactory<SignOut>(() => SignOut(getIt<AuthRepository>()))
    ..registerFactory<RefreshUserProfile>(
      () => RefreshUserProfile(getIt<AuthRepository>()),
    )
    ..registerFactory<PatchUserProfile>(
      () => PatchUserProfile(getIt<AuthRepository>()),
    )
    ..registerFactory<RequestEmailChange>(
      () => RequestEmailChange(getIt<AuthRepository>()),
    )
    ..registerFactoryParam<PersonalDataCubit, SyncProfile, void>(
      (syncProfile, _) => PersonalDataCubit(
        refreshUserProfile: getIt<RefreshUserProfile>(),
        patchUserProfile: getIt<PatchUserProfile>(),
        requestEmailChange: getIt<RequestEmailChange>(),
        syncProfile: syncProfile,
      ),
    )
    ..registerFactory<AuthCubit>(
      () => AuthCubit(
        getCurrentSession: getIt<GetCurrentSession>(),
        buildAuthorizationRequest: getIt<BuildAuthorizationRequest>(),
        exchangeAuthorizationCode: getIt<ExchangeAuthorizationCode>(),
        signOut: getIt<SignOut>(),
        refreshUserProfile: getIt<RefreshUserProfile>(),
      ),
    );
}

Dio _buildAuthenticatedDio(GetIt getIt, Environment environment) {
  final dio = DioClient.create(environment.authBaseUrl);
  dio.interceptors.add(
    AuthInterceptor(
      readAccessToken: () =>
          getIt<AuthLocalDataSource>().readSession()?.accessToken,
      refreshAccessToken: () async {
        final result = await getIt<AuthRepository>().currentSession();
        return switch (result) {
          Ok(:final value) => value?.accessToken,
          Err() => null,
        };
      },
      retryClient: DioClient.create(environment.authBaseUrl),
    ),
  );
  return dio;
}
