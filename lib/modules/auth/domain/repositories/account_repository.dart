import '../../../../core/result/result.dart';
import '../failures/account_failure.dart';
import '../value_objects/signup_form.dart';

abstract class AccountRepository {
  Future<Result<AccountFailure, void>> signUp(SignupForm form);
}
