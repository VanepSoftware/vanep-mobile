import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';
import '../value_objects/authorization_request.dart';

/// Exchanges the authorization code captured by the WebView for an
/// authenticated, persisted [AuthSession].
class ExchangeAuthorizationCode {
  const ExchangeAuthorizationCode(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthFailure, AuthSession>> call({
    required String code,
    required AuthorizationRequest request,
  }) {
    return _repository.exchangeCode(code: code, request: request);
  }
}
