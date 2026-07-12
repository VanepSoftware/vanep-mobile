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
