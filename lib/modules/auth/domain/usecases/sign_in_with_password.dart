import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignInWithPassword {
  const SignInWithPassword(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthFailure, AuthSession>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }
}
