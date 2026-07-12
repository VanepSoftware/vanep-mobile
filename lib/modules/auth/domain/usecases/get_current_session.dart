import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSession {
  const GetCurrentSession(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthFailure, AuthSession?>> call() {
    return _repository.currentSession();
  }
}
