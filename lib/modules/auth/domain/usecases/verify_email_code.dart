import '../../../../core/result/result.dart';
import '../failures/account_failure.dart';
import '../repositories/account_repository.dart';
import '../value_objects/account_field.dart';
import '../value_objects/signup_form.dart';

const int verificationCodeLength = 6;

class VerifyEmailCode {
  const VerifyEmailCode(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call({
    required String email,
    required String code,
  }) async {
    final digits = extractDigits(code);
    if (digits.length != verificationCodeLength) {
      return const Err(
        AccountValidationFailure({
          AccountField.code: AccountFieldIssue.invalid,
        }),
      );
    }
    return _repository.verifyEmail(email: email.trim(), code: digits);
  }
}
