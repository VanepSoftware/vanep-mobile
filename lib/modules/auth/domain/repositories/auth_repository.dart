import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../value_objects/authorization_request.dart';

abstract class AuthRepository {
  AuthorizationRequest buildAuthorizationRequest();

  Future<Result<AuthFailure, AuthSession>> exchangeCode({
    required String code,
    required AuthorizationRequest request,
  });

  Future<Result<AuthFailure, AuthSession?>> currentSession();

  Future<Result<AuthFailure, void>> signOut();
}
