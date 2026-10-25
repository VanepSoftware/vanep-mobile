import 'package:intl/intl.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';

String formatMoney(AppLocalizations l10n, int cents) {
  final format = NumberFormat.currency(
    locale: l10n.localeName,
    symbol: r'R$',
    decimalDigits: cents % 100 == 0 ? 0 : 2,
  );
  return format.format(cents / 100);
}
