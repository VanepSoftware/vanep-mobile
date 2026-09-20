import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/environment/environment.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../../core/result/result.dart';
import 'data/datasources/account_remote_datasource.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/oauth_remote_datasource.dart';
import 'data/datasources/user_profile_remote_datasource.dart';
import 'data/datasources/web_session_cleaner.dart';
import 'data/pkce/pkce_generator.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/build_authorization_request.dart';
import 'domain/usecases/exchange_authorization_code.dart';
import 'domain/usecases/get_current_session.dart';
import 'domain/usecases/patch_user_profile.dart';
import 'domain/usecases/refresh_user_profile.dart';
import 'domain/usecases/request_email_change.dart';
import 'domain/usecases/resend_email_verification_code.dart';
import 'domain/usecases/sign_in_with_password.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up.dart';
import 'domain/usecases/verify_email_code.dart';
import 'domain/value_objects/user_type.dart';
import 'presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/code_resend_cooldown.dart';
import 'presentation/cubit/email_code_verification_cubit.dart';
import 'presentation/cubit/email_code_verification_state.dart';
import 'presentation/cubit/login_cubit.dart';
import 'presentation/cubit/personal_data_cubit.dart';
import 'presentation/cubit/signup_cubit.dart';
import 'presentation/cubit/start_session.dart';

void registerAuthDependencies(
  GetIt getIt, {
  required FlutterSecureStorage secureStorage,
}) {
  final environment = getIt<Environment>();
  final oauthDio = DioClient.create(environment.authBaseUrl);

  getIt
    ..registerSingleton<OAuthRemoteDataSource>(
      OAuthRemoteDataSource(dio: oauthDio, environment: environment),
    )
    ..registerSingleton<AuthLocalDataSource>(AuthLocalDataSource(secureStorage))
    ..registerSingleton<AccountRepository>(
      AccountRepositoryImpl(
        remote: AccountRemoteDataSource(
          dio: oauthDio,
          environment: environment,
        ),
      ),
    )
    ..registerFactory<SignUp>(() => SignUp(getIt<AccountRepository>()))
    ..registerFactory<VerifyEmailCode>(
      () => VerifyEmailCode(getIt<AccountRepository>()),
    )
    ..registerFactory<ResendEmailVerificationCode>(
      () => ResendEmailVerificationCode(getIt<AccountRepository>()),
    )
    ..registerFactoryParam<
      EmailCodeVerificationCubit,
      EmailCodeVerificationRequest,
      StartSession
    >(
      (request, startSession) => EmailCodeVerificationCubit(
        verifyEmailCode: getIt<VerifyEmailCode>(),
        resendCode: getIt<ResendEmailVerificationCode>(),
        signInWithPassword: getIt<SignInWithPassword>(),
        startSession: startSession,
        cooldown: CodeResendCooldown(),
        email: request.email,
        password: request.password,
        codeAlreadySent: request.codeAlreadySent,
      ),
    )
    ..registerFactoryParam<SignupCubit, UserType, void>(
      (type, _) => SignupCubit(signUp: getIt<SignUp>(), type: type),
    )
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
    ..registerFactory<SignInWithPassword>(
      () => SignInWithPassword(getIt<AuthRepository>()),
    )
    ..registerFactoryParam<LoginCubit, StartSession, void>(
      (startSession, _) => LoginCubit(
        signInWithPassword: getIt<SignInWithPassword>(),
        startSession: startSession,
      ),
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
      readAccessToken: () async =>
          (await getIt<AuthLocalDataSource>().readSession())?.accessToken,
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
