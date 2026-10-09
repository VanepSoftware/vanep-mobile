import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';

class CompleteGoogleSignup {
  const CompleteGoogleSignup(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call({
    required String ticket,
    required SignupForm form,
  }) async {
    final issues = form.validate(includeCredentials: false);
    if (issues.isNotEmpty) return Err(AccountValidationFailure(issues));
    return _repository.completeGoogleSignup(ticket: ticket, form: form);
  }
}
