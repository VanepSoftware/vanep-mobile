import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/usecases/build_authorization_request.dart';
import '../../domain/usecases/exchange_authorization_code.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/value_objects/authorization_request.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._getCurrentSession,
    required this._buildAuthorizationRequest,
    required this._exchangeAuthorizationCode,
    required this._signOut,
  }) : super(const AuthUnknown());

  final GetCurrentSession _getCurrentSession;
  final BuildAuthorizationRequest _buildAuthorizationRequest;
  final ExchangeAuthorizationCode _exchangeAuthorizationCode;
  final SignOut _signOut;

  Future<void> checkSession() async {
    emit(const AuthUnknown());
    final result = await _getCurrentSession();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (session) => emit(
        session == null
            ? const AuthUnauthenticated()
            : AuthAuthenticated(session),
      ),
    );
  }

  void startLogin() {
    emit(AuthAuthenticating(_buildAuthorizationRequest()));
  }

  Future<void> submitAuthorizationCode(
    String code,
    AuthorizationRequest request,
  ) async {
    emit(const AuthExchanging());
    final result = await _exchangeAuthorizationCode(
      code: code,
      request: request,
    );
    result.fold(_emitFailure, (session) => emit(AuthAuthenticated(session)));
  }

  void cancelLogin() => _emitFailure(const CancelledAuthFailure());

  Future<void> signOut() async {
    await _signOut();
    emit(const AuthUnauthenticated());
  }

  void _emitFailure(AuthFailure failure) {
    emit(AuthFailureState(failure));
    emit(const AuthUnauthenticated());
  }
}
