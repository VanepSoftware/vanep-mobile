import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/presentation/formatters/profile_field_formatters.dart';

TextEditingValue textEditingValueAt(String text) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

void main() {
  late AppLocalizations l10nPt;
  late AppLocalizations l10nEn;

  setUpAll(() async {
    l10nPt = await AppLocalizations.delegate.load(const Locale('pt'));
    l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('profileGenderLabel translates known genders', () {
    expect(profileGenderLabel(Gender.male, l10nPt), 'Masculino');
    expect(profileGenderLabel(Gender.female, l10nPt), 'Feminino');
    expect(profileGenderLabel(Gender.other, l10nPt), 'Outro');
    expect(profileGenderLabel(null, l10nPt), '—');

    expect(profileGenderLabel(Gender.male, l10nEn), 'Male');
    expect(profileGenderLabel(Gender.female, l10nEn), 'Female');
    expect(profileGenderLabel(Gender.other, l10nEn), 'Other');
  });

  test('formatProfileBirthDate formats for locale', () {
    expect(
      formatProfileBirthDate('1990-05-15', const Locale('pt'), '—'),
      '15/05/1990',
    );
    expect(
      formatProfileBirthDate('1990-05-15', const Locale('en'), '—'),
      '5/15/1990',
    );
    expect(formatProfileBirthDate(null, const Locale('pt'), '—'), '—');
    expect(formatProfileBirthDate('not-a-date', const Locale('pt'), '—'), 'not-a-date');
  });

  test('formatProfilePhone masks Brazilian mobile and landline', () {
    expect(formatProfilePhone('11999999999', '—'), '(11) 99999-9999');
    expect(formatProfilePhone('1133334444', '—'), '(11) 3333-4444');
    expect(formatProfilePhone(null, '—'), '—');
    expect(formatProfilePhone('123', '—'), '123');
  });

  test('formatProfileDocument masks CPF', () {
    expect(formatProfileDocument('12345678901', '—'), '123.456.789-01');
    expect(formatProfileDocument(null, '—'), '—');
    expect(formatProfileDocument('ABC', '—'), 'ABC');
  });

  test('extractPhoneDigits strips everything but digits', () {
    expect(extractPhoneDigits('(11) 99999-9999'), '11999999999');
    expect(extractPhoneDigits('11 3333-4444'), '1133334444');
    expect(extractPhoneDigits(''), '');
  });

  test('formatProfilePhoneDigits builds mask progressively', () {
    expect(formatProfilePhoneDigits(''), '');
    expect(formatProfilePhoneDigits('1'), '(1');
    expect(formatProfilePhoneDigits('11'), '(11');
    expect(formatProfilePhoneDigits('1199'), '(11) 99');
    expect(formatProfilePhoneDigits('113333444'), '(11) 3333-444');
    expect(formatProfilePhoneDigits('1133334444'), '(11) 3333-4444');
    expect(formatProfilePhoneDigits('11999999999'), '(11) 99999-9999');
  });

  test(
    'ProfilePhoneInputFormatter masks digits and caps at 11',
    () {
      const formatter = ProfilePhoneInputFormatter();

      final afterTyping = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValueAt('11999999999'),
      );
      expect(afterTyping.text, '(11) 99999-9999');
      expect(afterTyping.selection.baseOffset, afterTyping.text.length);

      final withLetters = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValueAt('(11) abc99999-9999'),
      );
      expect(withLetters.text, '(11) 99999-9999');

      final overLimit = formatter.formatEditUpdate(
        TextEditingValue.empty,
        textEditingValueAt('119999999999999'),
      );
      expect(overLimit.text, '(11) 99999-9999');
    },
  );

  test('profileCooldownDaysRemaining rounds up to whole days', () {
    final now = DateTime(2026, 1, 1, 12);

    expect(
      profileCooldownDaysRemaining(DateTime(2026, 1, 4, 12), now: now),
      3,
    );
    expect(
      profileCooldownDaysRemaining(DateTime(2026, 1, 2, 13), now: now),
      2,
    );
    expect(
      profileCooldownDaysRemaining(DateTime(2026, 1, 1, 13), now: now),
      1,
    );
    expect(
      profileCooldownDaysRemaining(DateTime(2025, 12, 31), now: now),
      0,
    );
  });
}
