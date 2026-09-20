import '../../../../core/result/result.dart';
import '../failures/account_failure.dart';
import '../repositories/account_repository.dart';
import '../value_objects/account_field.dart';
import '../value_objects/password_policy.dart';
import '../value_objects/signup_form.dart';
import 'verify_email_code.dart';

abstract final class PasswordResetRules {
  static const int newPasswordMinLength = 8;
}

class ResetPasswordWithCode {
  const ResetPasswordWithCode(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final digits = extractDigits(code);
    final issues = {
      if (digits.length != verificationCodeLength)
        AccountField.code: AccountFieldIssue.invalid,
      AccountField.password: ?passwordIssueOf(
        newPassword,
        minLength: PasswordResetRules.newPasswordMinLength,
      ),
    };
    if (issues.isNotEmpty) return Err(AccountValidationFailure(issues));
    return _repository.resetPassword(
      email: email.trim(),
      code: digits,
      newPassword: newPassword,
    );
  }
}
