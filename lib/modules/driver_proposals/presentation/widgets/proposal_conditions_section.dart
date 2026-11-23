import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/core/ui/vanep_sheet.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_rows.dart';

class ProposalConditionsSection extends StatelessWidget {
  const ProposalConditionsSection({
    required this.conditions,
    required this.onConditionsChanged,
    super.key,
  });

  final ProposalConditions conditions;
  final ValueChanged<ProposalConditions>? onConditionsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onConditionsChanged = this.onConditionsChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(
          title: l10n.driverProposalConditionsSection,
          actionLabel: onConditionsChanged == null
              ? null
              : l10n.driverProposalEdit,
          onAction: onConditionsChanged == null
              ? null
              : () => showProposalConditionsSheet(
                  context,
                  conditions: conditions,
                  onSaved: onConditionsChanged,
                ),
        ),
        VanepRowsCard(
          rows: [
            ProposalDetailRow(
              label: l10n.driverProposalReservationFeeLabel,
              value: formatReservationFee(l10n, conditions.reservationFee),
            ),
            ProposalDetailRow(
              label: l10n.driverProposalReadjustmentLabel,
              value: formatReadjustment(l10n, conditions.readjustment),
            ),
            ProposalDetailRow(
              label: l10n.driverProposalCancellationLabel,
              value: formatCancellation(l10n, conditions),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showProposalConditionsSheet(
  BuildContext context, {
  required ProposalConditions conditions,
  required ValueChanged<ProposalConditions> onSaved,
}) {
  return showVanepSheet<void>(
    context,
    builder: (sheetContext) => ProposalConditionsSheet(
      initial: conditions,
      onSaved: (edited) {
        onSaved(edited);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

class ProposalConditionsSheet extends StatefulWidget {
  const ProposalConditionsSheet({
    required this.initial,
    required this.onSaved,
    super.key,
  });

  final ProposalConditions initial;
  final ValueChanged<ProposalConditions> onSaved;

  @override
  State<ProposalConditionsSheet> createState() =>
      ProposalConditionsSheetState();
}

class ProposalConditionsSheetState extends State<ProposalConditionsSheet> {
  late ProposalConditions conditions = widget.initial;

  void update(ProposalConditions edited) {
    setState(() => conditions = edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepSheetFrame(
      title: l10n.driverProposalConditionsSection,
      footer: VanepPrimaryButton(
        label: l10n.driverProposalSave,
        onPressed: () => widget.onSaved(conditions),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          VanepChoiceChips<ProposalReservationFee>(
            label: l10n.driverProposalReservationFeeLabel,
            choices: [
              for (final fee in ProposalReservationFee.values)
                VanepChoice(value: fee, label: formatReservationFee(l10n, fee)),
            ],
            selected: conditions.reservationFee,
            onSelected: (fee) =>
                update(conditions.copyWith(reservationFee: fee)),
          ),
          const SizedBox(height: 20),
          VanepChoiceChips<ProposalReadjustment>(
            label: l10n.driverProposalReadjustmentLabel,
            choices: [
              for (final readjustment in ProposalReadjustment.values)
                VanepChoice(
                  value: readjustment,
                  label: formatReadjustment(l10n, readjustment),
                ),
            ],
            selected: conditions.readjustment,
            onSelected: (readjustment) =>
                update(conditions.copyWith(readjustment: readjustment)),
          ),
          const SizedBox(height: 20),
          VanepChoiceChips<int>(
            label: l10n.driverProposalNoticeLabel,
            choices: [
              for (final days in proposalCancellationNoticeOptions)
                VanepChoice(
                  value: days,
                  label: l10n.driverProposalNoticeOption(days),
                ),
            ],
            selected: conditions.cancellationNoticeDays,
            onSelected: (days) =>
                update(conditions.copyWith(cancellationNoticeDays: days)),
          ),
          const SizedBox(height: 20),
          VanepChoiceChips<int>(
            label: l10n.driverProposalPenaltyLabel,
            choices: [
              for (final percent in proposalCancellationPenaltyOptions)
                VanepChoice(
                  value: percent,
                  label: l10n.driverProposalPenaltyOption(percent),
                ),
            ],
            selected: conditions.cancellationPenaltyPercent,
            onSelected: (percent) => update(
              conditions.copyWith(cancellationPenaltyPercent: percent),
            ),
          ),
        ],
      ),
    );
  }
}
