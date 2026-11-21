import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';

abstract class AccountRepository {
  Future<Result<AccountFailure, void>> signUp(SignupForm form);

  /// Fails with an [AccountValidationFailure] listing every field already
  /// taken by another account.
  Future<Result<AccountFailure, void>> checkSignupDuplicates({
    String? email,
    String? document,
    String? phone,
  });

  Future<Result<AccountFailure, void>> completeGoogleSignup({
    required String ticket,
    required SignupForm form,
  });

  Future<Result<AccountFailure, void>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Result<AccountFailure, void>> resendEmailVerification(String email);

  Future<Result<AccountFailure, void>> requestPasswordReset(String email);

  Future<Result<AccountFailure, void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
