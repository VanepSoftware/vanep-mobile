import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Resolves the current session at startup: returns the persisted (and, if
/// needed, refreshed) [AuthSession], or `null` when nobody is signed in.
class GetCurrentSession {
  const GetCurrentSession(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthFailure, AuthSession?>> call() {
    return _repository.currentSession();
  }
}
