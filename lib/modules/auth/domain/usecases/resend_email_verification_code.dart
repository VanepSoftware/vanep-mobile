import '../../../../core/result/result.dart';
import '../failures/account_failure.dart';
import '../repositories/account_repository.dart';

class ResendEmailVerificationCode {
  const ResendEmailVerificationCode(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call(String email) {
    return _repository.resendEmailVerification(email.trim());
  }
}
