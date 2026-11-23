import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/core/ui/vanep_sheet.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_rows.dart';

class ProposalPaymentSection extends StatelessWidget {
  const ProposalPaymentSection({
    required this.payment,
    required this.onPaymentChanged,
    super.key,
  });

  final ProposalPayment payment;
  final ValueChanged<ProposalPayment>? onPaymentChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPaymentChanged = this.onPaymentChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(title: l10n.driverProposalPaymentSection),
        VanepRowsCard(
          rows: [
            ProposalChevronRow(
              label: l10n.driverProposalInstallmentsLabel,
              value: formatProposalInstallments(l10n, payment),
              onTap: onPaymentChanged == null
                  ? null
                  : () => showProposalPaymentSheet(
                      context,
                      payment: payment,
                      onSaved: onPaymentChanged,
                    ),
            ),
            ProposalChevronRow(
              label: l10n.driverProposalPeriodLabel,
              value: formatProposalPeriod(l10n, payment),
              onTap: onPaymentChanged == null
                  ? null
                  : () => pickProposalPeriod(
                      context,
                      payment: payment,
                      onPicked: onPaymentChanged,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> pickProposalPeriod(
  BuildContext context, {
  required ProposalPayment payment,
  required ValueChanged<ProposalPayment> onPicked,
}) async {
  final picked = await showDateRangePicker(
    context: context,
    initialDateRange: DateTimeRange(
      start: payment.startDate,
      end: payment.endDate,
    ),
    firstDate: DateTime(payment.startDate.year - 1),
    lastDate: DateTime(payment.endDate.year + 2, 12, 31),
  );
  if (picked == null) return;
  onPicked(payment.copyWith(startDate: picked.start, endDate: picked.end));
}

Future<void> showProposalPaymentSheet(
  BuildContext context, {
  required ProposalPayment payment,
  required ValueChanged<ProposalPayment> onSaved,
}) {
  return showVanepSheet<void>(
    context,
    builder: (sheetContext) => ProposalPaymentSheet(
      initial: payment,
      onSaved: (edited) {
        onSaved(edited);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

class ProposalPaymentSheet extends StatefulWidget {
  const ProposalPaymentSheet({
    required this.initial,
    required this.onSaved,
    super.key,
  });

  final ProposalPayment initial;
  final ValueChanged<ProposalPayment> onSaved;

  @override
  State<ProposalPaymentSheet> createState() => ProposalPaymentSheetState();
}

class ProposalPaymentSheetState extends State<ProposalPaymentSheet> {
  late ProposalPayment payment = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepSheetFrame(
      title: l10n.driverProposalPaymentSheetTitle,
      footer: VanepPrimaryButton(
        label: l10n.driverProposalSave,
        onPressed: () => widget.onSaved(payment),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          VanepChoiceChips<int>(
            label: l10n.driverProposalInstallmentsLabel,
            choices: [
              for (var count = 1; count <= maxProposalInstallments; count++)
                VanepChoice(
                  value: count,
                  label: l10n.driverProposalInstallmentsOption(count),
                ),
            ],
            selected: payment.installments,
            onSelected: (count) => setState(
              () => payment = payment.copyWith(installments: count),
            ),
          ),
          const SizedBox(height: 20),
          VanepChoiceChips<int>(
            label: l10n.driverProposalDueDayLabel,
            choices: [
              for (final day in proposalDueDayOptions)
                VanepChoice(
                  value: day,
                  label: l10n.driverProposalDueDayOption(day),
                ),
            ],
            selected: payment.dueDay,
            onSelected: (day) =>
                setState(() => payment = payment.copyWith(dueDay: day)),
          ),
        ],
      ),
    );
  }
}
