import '../../../../core/result/result.dart';
import '../failures/account_failure.dart';
import '../repositories/account_repository.dart';
import '../value_objects/account_field.dart';
import '../value_objects/signup_form.dart';

class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return const Err(
        AccountValidationFailure({
          AccountField.email: AccountFieldIssue.required,
        }),
      );
    }
    if (!isValidEmail(trimmed)) {
      return const Err(
        AccountValidationFailure({
          AccountField.email: AccountFieldIssue.invalid,
        }),
      );
    }
    return _repository.requestPasswordReset(trimmed);
  }
}
