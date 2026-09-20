import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/refresh_user_profile.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._getCurrentSession,
    required this._signOut,
    required this._refreshUserProfile,
  }) : super(const AuthUnknown());

  final GetCurrentSession _getCurrentSession;
  final SignOut _signOut;
  final RefreshUserProfile _refreshUserProfile;

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

  void startSession(AuthSession session) => emit(AuthAuthenticated(session));

  Future<void> signOut() async {
    await _signOut();
    emit(const AuthUnauthenticated());
  }

  void syncProfile(UserProfile profile) {
    final current = state;
    if (current is! AuthAuthenticated) return;
    emit(
      AuthAuthenticated(AuthSessionReplacingProfile(current.session, profile)),
    );
  }

  Future<void> refreshSessionProfile() async {
    if (state is! AuthAuthenticated) return;
    final result = await _refreshUserProfile();
    result.fold((_) {}, syncProfile);
  }
}
