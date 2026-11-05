import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';

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
