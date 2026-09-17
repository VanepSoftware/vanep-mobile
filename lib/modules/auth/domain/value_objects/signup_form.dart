import 'package:equatable/equatable.dart';

import 'account_field.dart';
import 'gender.dart';
import 'user_type.dart';

abstract final class SignupRules {
  static const int passwordMinLength = 6;
}

class SignupForm extends Equatable {
  const SignupForm({
    required this.type,
    this.name = '',
    this.email = '',
    this.password = '',
    this.document = '',
    this.phone = '',
    this.birthDate,
    this.gender,
    this.acceptTerms = false,
    this.basePrice = '',
    this.cnpj = '',
    this.experienceYears = '',
  });

  final UserType type;
  final String name;
  final String email;
  final String password;
  final String document;
  final String phone;
  final DateTime? birthDate;
  final Gender? gender;
  final bool acceptTerms;
  final String basePrice;
  final String cnpj;
  final String experienceYears;

  bool get isDriver => type == UserType.driver;

  String get documentDigits => extractDigits(document);

  String get phoneDigits => extractDigits(phone);

  String get cnpjDigits => extractDigits(cnpj);

  double? get basePriceValue => parseDecimal(basePrice);

  int? get experienceYearsValue => int.tryParse(experienceYears.trim());

  Map<AccountField, AccountFieldIssue> validate({
    bool includeCredentials = true,
  }) {
    return {
      if (includeCredentials) ...credentialIssuesOf(this),
      ...profileIssuesOf(this),
      if (isDriver) ...driverIssuesOf(this),
    };
  }

  SignupForm copyWith({
    UserType? type,
    String? name,
    String? email,
    String? password,
    String? document,
    String? phone,
    DateTime? birthDate,
    bool clearBirthDate = false,
    Gender? gender,
    bool? acceptTerms,
    String? basePrice,
    String? cnpj,
    String? experienceYears,
  }) {
    return SignupForm(
      type: type ?? this.type,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      document: document ?? this.document,
      phone: phone ?? this.phone,
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      gender: gender ?? this.gender,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      basePrice: basePrice ?? this.basePrice,
      cnpj: cnpj ?? this.cnpj,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }

  @override
  List<Object?> get props => [
    type,
    name,
    email,
    password,
    document,
    phone,
    birthDate,
    gender,
    acceptTerms,
    basePrice,
    cnpj,
    experienceYears,
  ];
}

Map<AccountField, AccountFieldIssue> credentialIssuesOf(SignupForm form) {
  final email = form.email.trim();
  return {
    if (form.name.trim().isEmpty) AccountField.name: AccountFieldIssue.required,
    if (email.isEmpty)
      AccountField.email: AccountFieldIssue.required
    else if (!isValidEmail(email))
      AccountField.email: AccountFieldIssue.invalid,
    if (form.password.isEmpty)
      AccountField.password: AccountFieldIssue.required
    else if (form.password.length < SignupRules.passwordMinLength)
      AccountField.password: AccountFieldIssue.tooShort,
  };
}

Map<AccountField, AccountFieldIssue> profileIssuesOf(SignupForm form) {
  return {
    if (form.documentDigits.isEmpty)
      AccountField.document: AccountFieldIssue.required
    else if (!isValidCpf(form.documentDigits))
      AccountField.document: AccountFieldIssue.invalid,
    if (!form.acceptTerms)
      AccountField.acceptTerms: AccountFieldIssue.notAccepted,
  };
}

Map<AccountField, AccountFieldIssue> driverIssuesOf(SignupForm form) {
  final basePrice = form.basePriceValue;
  final experienceYears = form.experienceYearsValue;
  return {
    if (form.basePrice.trim().isEmpty)
      AccountField.basePrice: AccountFieldIssue.required
    else if (basePrice == null)
      AccountField.basePrice: AccountFieldIssue.invalid
    else if (basePrice <= 0)
      AccountField.basePrice: AccountFieldIssue.notPositive,
    if (form.experienceYears.trim().isNotEmpty &&
        (experienceYears == null || experienceYears < 0))
      AccountField.experienceYears: AccountFieldIssue.invalid,
  };
}

String extractDigits(String raw) => raw.replaceAll(RegExp(r'\D'), '');

double? parseDecimal(String raw) {
  final trimmed = raw.trim();
  final normalized = trimmed.contains(',')
      ? trimmed.replaceAll('.', '').replaceAll(',', '.')
      : trimmed;
  return double.tryParse(normalized);
}

final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String email) => emailPattern.hasMatch(email.trim());

bool isValidCpf(String raw) {
  final digits = extractDigits(raw);
  if (digits.length != 11) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;
  final numbers = digits.split('').map(int.parse).toList();
  return cpfCheckDigit(numbers.sublist(0, 9)) == numbers[9] &&
      cpfCheckDigit(numbers.sublist(0, 10)) == numbers[10];
}

int cpfCheckDigit(List<int> numbers) {
  var sum = 0;
  for (var index = 0; index < numbers.length; index++) {
    sum += numbers[index] * (numbers.length + 1 - index);
  }
  final remainder = (sum * 10) % 11;
  return remainder == 10 ? 0 : remainder;
}
