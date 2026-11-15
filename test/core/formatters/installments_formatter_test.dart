import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  test(
    'shows the installments the back calculated, without cents when round',
    () {
      expect(formatInstallments(l10n, 12, 30000), 'R\$ 300/mês · 12x');
    },
  );

  test('keeps the cents of an amount that does not divide exactly', () {
    expect(formatInstallments(l10n, 3, 33333), 'R\$ 333,33/mês · 3x');
  });

  test('a single installment is paid upfront', () {
    expect(formatInstallments(l10n, 1, 360000), 'R\$ 3.600 à vista');
  });
}
