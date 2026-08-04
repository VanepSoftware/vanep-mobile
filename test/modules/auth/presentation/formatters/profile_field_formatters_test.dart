import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/presentation/formatters/profile_field_formatters.dart';

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
}
