import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/formatters/gender_label.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

void main() {
  test('labels every gender and the omitted choice in Portuguese', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));

    expect(genderLabel(Gender.male, l10n), 'Masculino');
    expect(genderLabel(Gender.female, l10n), 'Feminino');
    expect(genderLabel(Gender.other, l10n), 'Outro');
    expect(genderLabel(null, l10n), 'Prefiro não informar');
  });

  test('labels every gender and the omitted choice in English', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(genderLabel(Gender.male, l10n), 'Male');
    expect(genderLabel(Gender.female, l10n), 'Female');
    expect(genderLabel(Gender.other, l10n), 'Other');
    expect(genderLabel(null, l10n), 'Prefer not to say');
  });
}
