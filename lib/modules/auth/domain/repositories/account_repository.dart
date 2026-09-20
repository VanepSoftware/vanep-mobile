import '../../../../core/result/result.dart';
import '../failures/account_failure.dart';
import '../value_objects/signup_form.dart';

abstract class AccountRepository {
  Future<Result<AccountFailure, void>> signUp(SignupForm form);

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
