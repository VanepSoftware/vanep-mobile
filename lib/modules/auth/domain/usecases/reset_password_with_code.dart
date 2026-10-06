import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/password_policy.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/verify_email_code.dart';

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
