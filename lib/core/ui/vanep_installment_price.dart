import 'package:flutter/widgets.dart';

import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';

class VanepInstallmentPrice extends StatelessWidget {
  const VanepInstallmentPrice({
    required this.amountCents,
    required this.installments,
    required this.amountStyle,
    required this.countStyle,
    super.key,
  });

  final int amountCents;
  final int installments;
  final TextStyle amountStyle;
  final TextStyle countStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text.rich(
      TextSpan(
        text: formatMoney(l10n, amountCents),
        style: amountStyle,
        children: [
          TextSpan(
            text: installments > 1
                ? l10n.installmentPriceMonthly(installments)
                : ' ${l10n.installmentPriceUpfront}',
            style: countStyle,
          ),
        ],
      ),
      maxLines: 1,
      softWrap: false,
    );
  }
}
