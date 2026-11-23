import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/core/ui/vanep_sheet.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_rows.dart';

class ProposalTimesSection extends StatelessWidget {
  const ProposalTimesSection({
    required this.times,
    required this.onTimesChanged,
    super.key,
  });

  final ProposalRouteTimes times;
  final ValueChanged<ProposalRouteTimes>? onTimesChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onTimesChanged = this.onTimesChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(
          title: l10n.driverProposalTimesSection,
          actionLabel: onTimesChanged == null ? null : l10n.driverProposalEdit,
          onAction: onTimesChanged == null
              ? null
              : () => showProposalTimesSheet(
                  context,
                  times: times,
                  onSaved: onTimesChanged,
                ),
        ),
        VanepRowsCard(
          rows: [
            ProposalDetailRow(
              label: l10n.driverProposalPickupLabel,
              value: formatPickupWindow(l10n, times),
            ),
            ProposalDetailRow(
              label: l10n.driverProposalArrivalLabel,
              value: formatProposalClock(l10n, times.schoolArrivalMinutes),
            ),
            ProposalDetailRow(
              label: l10n.driverProposalDepartureLabel,
              value: formatProposalClock(l10n, times.schoolDepartureMinutes),
            ),
            ProposalDetailRow(
              label: l10n.driverProposalStopWaitLabel,
              value: l10n.driverProposalStopWaitValue(times.stopWaitMinutes),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showProposalTimesSheet(
  BuildContext context, {
  required ProposalRouteTimes times,
  required ValueChanged<ProposalRouteTimes> onSaved,
}) {
  return showVanepSheet<void>(
    context,
    builder: (sheetContext) => ProposalTimesSheet(
      initial: times,
      onSaved: (edited) {
        onSaved(edited);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

Future<int?> pickProposalClock(BuildContext context, int minutesFromMidnight) {
  return showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: minutesFromMidnight ~/ 60,
      minute: minutesFromMidnight % 60,
    ),
  ).then((picked) => picked == null ? null : picked.hour * 60 + picked.minute);
}

class ProposalTimesSheet extends StatefulWidget {
  const ProposalTimesSheet({
    required this.initial,
    required this.onSaved,
    super.key,
  });

  final ProposalRouteTimes initial;
  final ValueChanged<ProposalRouteTimes> onSaved;

  @override
  State<ProposalTimesSheet> createState() => ProposalTimesSheetState();
}

class ProposalTimesSheetState extends State<ProposalTimesSheet> {
  late ProposalRouteTimes times = widget.initial;

  Future<void> editClock(
    int current,
    ProposalRouteTimes Function(int minutes) apply,
  ) async {
    final picked = await pickProposalClock(context, current);
    if (picked == null || !mounted) return;
    setState(() => times = apply(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepSheetFrame(
      title: l10n.driverProposalTimesSection,
      footer: VanepPrimaryButton(
        label: l10n.driverProposalSave,
        onPressed: times.isValid ? () => widget.onSaved(times) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          VanepRowsCard(
            rows: [
              ProposalChevronRow(
                label: l10n.driverProposalPickupStartLabel,
                value: formatProposalClock(l10n, times.pickupStartMinutes),
                onTap: () => editClock(
                  times.pickupStartMinutes,
                  (minutes) => times.copyWith(pickupStartMinutes: minutes),
                ),
              ),
              ProposalChevronRow(
                label: l10n.driverProposalPickupEndLabel,
                value: formatProposalClock(l10n, times.pickupEndMinutes),
                onTap: () => editClock(
                  times.pickupEndMinutes,
                  (minutes) => times.copyWith(pickupEndMinutes: minutes),
                ),
              ),
              ProposalChevronRow(
                label: l10n.driverProposalArrivalLabel,
                value: formatProposalClock(l10n, times.schoolArrivalMinutes),
                onTap: () => editClock(
                  times.schoolArrivalMinutes,
                  (minutes) => times.copyWith(schoolArrivalMinutes: minutes),
                ),
              ),
              ProposalChevronRow(
                label: l10n.driverProposalDepartureLabel,
                value: formatProposalClock(l10n, times.schoolDepartureMinutes),
                onTap: () => editClock(
                  times.schoolDepartureMinutes,
                  (minutes) => times.copyWith(schoolDepartureMinutes: minutes),
                ),
              ),
            ],
          ),
          if (!times.isValid) ...[
            const SizedBox(height: 8),
            Text(
              l10n.driverProposalTimesInvalid,
              style: VanepTypography.cardSubtitle.copyWith(
                color: VanepColors.danger,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 20),
          VanepChoiceChips<int>(
            label: l10n.driverProposalStopWaitLabel,
            choices: [
              for (final minutes in proposalStopWaitOptions)
                VanepChoice(
                  value: minutes,
                  label: l10n.driverProposalStopWaitValue(minutes),
                ),
            ],
            selected: times.stopWaitMinutes,
            onSelected: (minutes) => setState(
              () => times = times.copyWith(stopWaitMinutes: minutes),
            ),
          ),
        ],
      ),
    );
  }
}
