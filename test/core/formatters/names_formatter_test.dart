import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

void main() {
  test('joins names with commas and the last separator', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));

    expect(joinNames(l10n, []), '');
    expect(joinNames(l10n, ['Ana']), 'Ana');
    expect(joinNames(l10n, ['Ana', 'Pedro']), 'Ana e Pedro');
    expect(joinNames(l10n, ['Ana', 'Pedro', 'Lucas']), 'Ana, Pedro e Lucas');
  });

  test('the first name is the first word of the full name', () {
    expect(firstNameOf('  Ana Souza Lima '), 'Ana');
    expect(firstNameOf('Pedro'), 'Pedro');
    expect(firstNameOf('   '), '');
  });

  test('joins the first names of full names', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('pt'));

    expect(joinFirstNames(l10n, ['Ana Souza', 'Pedro Souza']), 'Ana e Pedro');
  });
}
