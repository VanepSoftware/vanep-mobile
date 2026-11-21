import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/repositories/account_repository.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';

/// Asks the API whether the given fields of [form] are already taken, so the
/// wizard can warn before the user moves to the next step.
class CheckSignupDuplicates {
  const CheckSignupDuplicates(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountFailure, void>> call(
    SignupForm form,
    Set<AccountField> fields,
  ) async {
    final email = fields.contains(AccountField.email) ? form.email.trim() : '';
    final document = fields.contains(AccountField.document)
        ? form.documentDigits
        : '';
    final phone = fields.contains(AccountField.phone) ? form.phoneDigits : '';
    if (email.isEmpty && document.isEmpty && phone.isEmpty) {
      return const Ok(null);
    }
    return _repository.checkSignupDuplicates(
      email: email.isEmpty ? null : email,
      document: document.isEmpty ? null : document,
      phone: phone.isEmpty ? null : phone,
    );
  }
}
