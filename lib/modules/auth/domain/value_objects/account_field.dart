enum AccountField {
  name,
  email,
  password,
  passwordConfirmation,
  document,
  phone,
  birthDate,
  gender,
  acceptTerms,
  basePrice,
  cnpj,
  experienceYears,
  code;

  static AccountField? fromApi(String? raw) {
    return switch (raw) {
      'name' => AccountField.name,
      'email' => AccountField.email,
      'password' || 'newPassword' => AccountField.password,
      'document' => AccountField.document,
      'phone' => AccountField.phone,
      'birthDate' => AccountField.birthDate,
      'gender' => AccountField.gender,
      'acceptTerms' => AccountField.acceptTerms,
      'basePrice' || 'driverFieldsComplete' => AccountField.basePrice,
      'cnpj' => AccountField.cnpj,
      'experienceYears' => AccountField.experienceYears,
      'code' => AccountField.code,
      _ => null,
    };
  }
}

enum AccountFieldIssue {
  required,
  invalid,
  tooShort,
  missingUppercase,
  missingSpecialCharacter,
  mismatch,
  notAccepted,
  notPositive,
  duplicate,
  rejected,
}

Map<AccountField, AccountFieldIssue> accountIssuesWithout(
  Map<AccountField, AccountFieldIssue> issues,
  AccountField field,
) {
  if (!issues.containsKey(field)) return issues;
  return Map<AccountField, AccountFieldIssue>.from(issues)..remove(field);
}
