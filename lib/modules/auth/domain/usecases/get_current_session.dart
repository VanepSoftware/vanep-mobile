import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/auth_repository.dart';

class GetCurrentSession {
  const GetCurrentSession(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthFailure, AuthSession?>> call() {
    return _repository.currentSession();
  }
}
