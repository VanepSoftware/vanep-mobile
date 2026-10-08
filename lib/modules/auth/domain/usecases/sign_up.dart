import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';

class SignUp {
  const SignUp(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call(SignupForm form) async {
    final issues = form.validate();
    if (issues.isNotEmpty) return Err(AccountValidationFailure(issues));
    return _repository.signUp(form);
  }
}
