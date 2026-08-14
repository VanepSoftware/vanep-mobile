import 'user_profile.dart';

abstract class AuthSession {
  String get accessToken;

  String get refreshToken;

  DateTime get expiresAt;

  UserProfile get profile;
}

extension AuthSessionExpiry on AuthSession {
  bool isExpired(
    DateTime now, {
    Duration leeway = const Duration(seconds: 30),
  }) {
    return !now.add(leeway).isBefore(expiresAt);
  }
}

class AuthSessionReplacingProfile implements AuthSession {
  const AuthSessionReplacingProfile(this.base, this.profile);

  final AuthSession base;

  @override
  final UserProfile profile;

  @override
  String get accessToken => base.accessToken;

  @override
  String get refreshToken => base.refreshToken;

  @override
  DateTime get expiresAt => base.expiresAt;
}
