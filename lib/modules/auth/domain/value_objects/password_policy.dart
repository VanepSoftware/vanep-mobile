import 'account_field.dart';

abstract final class PasswordPolicy {
  static const int minLength = 6;
}

final RegExp uppercaseLetterPattern = RegExp(r'\p{Lu}', unicode: true);

final RegExp specialCharacterPattern = RegExp(
  r'[^\p{L}\p{N}\s]',
  unicode: true,
);

enum PasswordRequirement {
  minLength,
  uppercaseLetter,
  specialCharacter;

  bool isMetBy(String password, {int minLength = PasswordPolicy.minLength}) {
    return switch (this) {
      PasswordRequirement.minLength => password.length >= minLength,
      PasswordRequirement.uppercaseLetter => uppercaseLetterPattern.hasMatch(
        password,
      ),
      PasswordRequirement.specialCharacter => specialCharacterPattern.hasMatch(
        password,
      ),
    };
  }
}

AccountFieldIssue? passwordIssueOf(
  String password, {
  int minLength = PasswordPolicy.minLength,
}) {
  if (password.isEmpty) return AccountFieldIssue.required;
  if (!PasswordRequirement.minLength.isMetBy(password, minLength: minLength)) {
    return AccountFieldIssue.tooShort;
  }
  if (!PasswordRequirement.uppercaseLetter.isMetBy(password)) {
    return AccountFieldIssue.missingUppercase;
  }
  if (!PasswordRequirement.specialCharacter.isMetBy(password)) {
    return AccountFieldIssue.missingSpecialCharacter;
  }
  return null;
}

AccountFieldIssue? passwordConfirmationIssueOf({
  required String password,
  required String confirmation,
}) {
  if (confirmation.isEmpty) return AccountFieldIssue.required;
  if (confirmation != password) return AccountFieldIssue.mismatch;
  return null;
}
