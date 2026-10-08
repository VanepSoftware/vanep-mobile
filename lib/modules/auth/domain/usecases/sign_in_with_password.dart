import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/auth_repository.dart';

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
