import 'user_profile.dart';

/// A successful OAuth session: the tokens plus the profile they belong to.
///
/// Abstract (constitution R04) — the data layer's DTO implements it and handles
/// (de)serialization for Hive persistence. Kept to pure getters so DTOs only
/// implement data, not behavior (expiry lives in [AuthSessionExpiry]).
abstract class AuthSession {
  /// Bearer token sent on authenticated API calls.
  String get accessToken;

  /// Token used to obtain a fresh [accessToken] via the refresh grant.
  String get refreshToken;

  /// Absolute instant when [accessToken] stops being valid.
  DateTime get expiresAt;

  /// Profile of the authenticated user.
  UserProfile get profile;
}

/// Expiry check shared by every [AuthSession] implementation.
extension AuthSessionExpiry on AuthSession {
  /// Whether [accessToken] is already past (or within [leeway] of) [expiresAt].
  bool isExpired(DateTime now, {Duration leeway = const Duration(seconds: 30)}) {
    return !now.add(leeway).isBefore(expiresAt);
  }
}
