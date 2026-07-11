import '../../../../core/result/result.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Revokes the tokens on the backend and clears the local session.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthFailure, void>> call() => _repository.signOut();
}
