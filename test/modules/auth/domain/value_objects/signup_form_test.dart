import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/password_policy.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

import '../../account_fixtures.dart';

void main() {
  group('isValidCpf', () {
    test('accepts valid check digits with or without punctuation', () {
      expect(isValidCpf('52998224725'), isTrue);
      expect(isValidCpf(validCpf), isTrue);
    });

    test('rejects wrong check digits, repeated digits and wrong length', () {
      expect(isValidCpf('52998224726'), isFalse);
      expect(isValidCpf('11111111111'), isFalse);
      expect(isValidCpf('5299822472'), isFalse);
    });
  });

  group('isValidEmail', () {
    test('accepts a common address and rejects malformed ones', () {
      expect(isValidEmail('ana@vanep.com.br'), isTrue);
      expect(isValidEmail('ana@vanep'), isFalse);
      expect(isValidEmail('ana vanep.com'), isFalse);
    });
  });

  group('parsed values', () {
    test('reads Brazilian and dotted decimal base prices', () {
      expect(validDriverSignupForm.basePriceValue, 1250.5);
      expect(
        validDriverSignupForm.copyWith(basePrice: '99.9').basePriceValue,
        99.9,
      );
      expect(
        validDriverSignupForm.copyWith(basePrice: 'abc').basePriceValue,
        isNull,
      );
    });

    test('keeps only digits of document, phone and CNPJ', () {
      expect(validDriverSignupForm.documentDigits, '52998224725');
      expect(validDriverSignupForm.phoneDigits, '11999990000');
      expect(validDriverSignupForm.cnpjDigits, '11222333000181');
      expect(validDriverSignupForm.experienceYearsValue, 7);
    });
  });

  group('validate', () {
    test('a complete client form has no issues', () {
      expect(validClientSignupForm.validate(), isEmpty);
    });

    test('a complete driver form has no issues', () {
      expect(validDriverSignupForm.validate(), isEmpty);
    });

    test('an empty form reports every required field', () {
      const form = SignupForm(type: UserType.driver);

      expect(form.validate(), {
        AccountField.name: AccountFieldIssue.required,
        AccountField.email: AccountFieldIssue.required,
        AccountField.password: AccountFieldIssue.required,
        AccountField.passwordConfirmation: AccountFieldIssue.required,
        AccountField.document: AccountFieldIssue.required,
        AccountField.acceptTerms: AccountFieldIssue.notAccepted,
        AccountField.basePrice: AccountFieldIssue.required,
      });
    });

    test('reports malformed values', () {
      final form = validDriverSignupForm.copyWith(
        email: 'ana@',
        password: '12345',
        passwordConfirmation: '12345',
        document: '52998224726',
        basePrice: '0',
        experienceYears: 'dez',
      );

      expect(form.validate(), {
        AccountField.email: AccountFieldIssue.invalid,
        AccountField.password: AccountFieldIssue.tooShort,
        AccountField.document: AccountFieldIssue.invalid,
        AccountField.basePrice: AccountFieldIssue.notPositive,
        AccountField.experienceYears: AccountFieldIssue.invalid,
      });
    });

    test('driver fields are ignored for other account types', () {
      final form = validClientSignupForm.copyWith(basePrice: 'abc');

      expect(form.validate(), isEmpty);
    });

    test('credentials are skipped when the account comes from Google', () {
      final form = validClientSignupForm.copyWith(
        name: '',
        email: '',
        password: '',
      );

      expect(form.validate(includeCredentials: false), isEmpty);
    });
  });

  group('AccountField.fromApi', () {
    test('maps API field names, including aliases', () {
      expect(AccountField.fromApi('document'), AccountField.document);
      expect(AccountField.fromApi('newPassword'), AccountField.password);
      expect(
        AccountField.fromApi('driverFieldsComplete'),
        AccountField.basePrice,
      );
      expect(AccountField.fromApi('unknown'), isNull);
      expect(AccountField.fromApi(null), isNull);
    });
  });

  group('password policy', () {
    test('each requirement is checked on its own', () {
      expect(PasswordRequirement.minLength.isMetBy('Ab@12'), isFalse);
      expect(PasswordRequirement.minLength.isMetBy('Ab@123'), isTrue);
      expect(PasswordRequirement.uppercaseLetter.isMetBy('secret@1'), isFalse);
      expect(PasswordRequirement.uppercaseLetter.isMetBy('Ásecret'), isTrue);
      expect(PasswordRequirement.specialCharacter.isMetBy('Secret12'), isFalse);
      expect(
        PasswordRequirement.specialCharacter.isMetBy('Senha com espaco'),
        isFalse,
      );
      expect(PasswordRequirement.specialCharacter.isMetBy('Secret.1'), isTrue);
    });

    test('a password without uppercase or special character is rejected', () {
      expect(
        validClientSignupForm
            .copyWith(password: 'secret@1', passwordConfirmation: 'secret@1')
            .validate()[AccountField.password],
        AccountFieldIssue.missingUppercase,
      );
      expect(
        validClientSignupForm
            .copyWith(password: 'Secret12', passwordConfirmation: 'Secret12')
            .validate()[AccountField.password],
        AccountFieldIssue.missingSpecialCharacter,
      );
    });

    test('the confirmation must match the password', () {
      expect(
        validClientSignupForm
            .copyWith(passwordConfirmation: 'Secret@2')
            .validate(),
        {AccountField.passwordConfirmation: AccountFieldIssue.mismatch},
      );
    });
  });
}
