import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_schedule.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

const proposalGridLabelWidth = 52.0;

class ProposalScheduleSection extends StatelessWidget {
  const ProposalScheduleSection({
    required this.draft,
    required this.onSlotToggled,
    super.key,
  });

  final ProposalComposeDraft draft;
  final ValueChanged<ProposalScheduleSlot>? onSlotToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matches = draft.matchesRequest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(title: l10n.driverProposalScheduleSection),
        VanepCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProposalGridHeader(
                labels: [
                  for (final weekday in schoolWeekdays)
                    formatWeekdayShortName(l10n, weekday),
                ],
              ),
              for (final leg in RouteLeg.values) ...[
                const SizedBox(height: 8),
                ProposalGridLegRow(
                  label: formatRouteLeg(l10n, leg),
                  cells: [
                    for (final weekday in schoolWeekdays)
                      ProposalScheduleSlot(weekday: weekday, leg: leg),
                  ],
                  selected: draft.slots,
                  onSlotToggled: onSlotToggled,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                matches
                    ? l10n.driverProposalScheduleMatchesRequest
                    : l10n.driverProposalScheduleDiffers,
                style: VanepTypography.cardSubtitle.copyWith(
                  fontSize: 12,
                  color: matches
                      ? VanepColors.textSecondary
                      : VanepColors.warning,
                  fontWeight: matches ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProposalGridHeader extends StatelessWidget {
  const ProposalGridHeader({required this.labels, super.key});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: proposalGridLabelWidth),
        for (final label in labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class ProposalGridLegRow extends StatelessWidget {
  const ProposalGridLegRow({
    required this.label,
    required this.cells,
    required this.selected,
    required this.onSlotToggled,
    super.key,
  });

  final String label;
  final List<ProposalScheduleSlot> cells;
  final Set<ProposalScheduleSlot> selected;
  final ValueChanged<ProposalScheduleSlot>? onSlotToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSlotToggled = this.onSlotToggled;
    return Row(
      children: [
        SizedBox(
          width: proposalGridLabelWidth,
          child: Text(
            label,
            style: VanepTypography.cardTitle.copyWith(fontSize: 14),
          ),
        ),
        for (final slot in cells)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: ProposalGridCell(
                semanticLabel:
                    '${formatWeekdayName(l10n, slot.weekday)}, $label',
                isOn: selected.contains(slot),
                onTap: onSlotToggled == null
                    ? null
                    : () => onSlotToggled(slot),
              ),
            ),
          ),
      ],
    );
  }
}

class ProposalGridCell extends StatelessWidget {
  const ProposalGridCell({
    required this.semanticLabel,
    required this.isOn,
    required this.onTap,
    super.key,
  });

  final String semanticLabel;
  final bool isOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      checked: isOn,
      button: true,
      child: Material(
        color: isOn ? VanepColors.actionSurface : VanepColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VanepTheme.controlRadius - 2),
          side: BorderSide(
            color: isOn ? Colors.transparent : VanepColors.inputBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 36,
            child: isOn
                ? const Icon(Icons.check, size: 18, color: VanepColors.action)
                : null,
          ),
        ),
      ),
    );
  }
}
