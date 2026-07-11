import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../value_objects/authorization_request.dart';

/// Contract for the auth feature (constitution R01/R07). Presentation depends on
/// this, never on the data implementation.
abstract class AuthRepository {
  /// Builds a fresh authorization request (URL + PKCE verifier + state).
  ///
  /// Synchronous and side-effect free apart from generating random values.
  AuthorizationRequest buildAuthorizationRequest();

  /// Exchanges the [code] returned by the WebView for tokens, fetches the
  /// profile, persists the session and returns it.
  Future<Result<AuthFailure, AuthSession>> exchangeCode({
    required String code,
    required AuthorizationRequest request,
  });

  /// Returns the persisted session (refreshing it when the access token is
  /// expired), or `null` when the user is not authenticated.
  Future<Result<AuthFailure, AuthSession?>> currentSession();

  /// Revokes the tokens on the backend and clears the local session.
  Future<Result<AuthFailure, void>> signOut();
}
