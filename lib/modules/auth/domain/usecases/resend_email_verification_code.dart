import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';

class ResendEmailVerificationCode {
  const ResendEmailVerificationCode(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call(String email) {
    return _repository.resendEmailVerification(email.trim());
  }
}
