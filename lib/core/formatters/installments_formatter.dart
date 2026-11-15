import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

String formatInstallments(
  AppLocalizations l10n,
  int installments,
  int installmentAmountCents,
) {
  return l10n.negotiationInstallments(
    installments,
    formatMoney(l10n, installmentAmountCents),
  );
}
