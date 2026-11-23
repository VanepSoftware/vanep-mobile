import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/core/ui/vanep_sheet.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

class ProposalVanSection extends StatelessWidget {
  const ProposalVanSection({
    required this.draft,
    required this.onVanSelected,
    super.key,
  });

  final ProposalComposeDraft draft;
  final ValueChanged<String>? onVanSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final van = draft.selectedVan;
    final onVanSelected = this.onVanSelected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(title: l10n.driverProposalVanSection),
        VanepCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          onTap: onVanSelected == null || draft.vans.length < 2
              ? null
              : () => showProposalVanSheet(
                  context,
                  draft: draft,
                  onVanSelected: onVanSelected,
                ),
          child: Row(
            children: [
              const Icon(
                Icons.airport_shuttle_outlined,
                size: 20,
                color: VanepColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  van == null ? '' : formatProposalVanName(l10n, van),
                  style: VanepTypography.cardTitle.copyWith(fontSize: 15),
                ),
              ),
              if (draft.vans.length > 1)
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: VanepColors.textSecondary,
                ),
            ],
          ),
        ),
        if (van != null) ...[
          const SizedBox(height: 8),
          Text(
            formatProposalVanSeats(l10n, draft.shift, van),
            style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
          ),
        ],
        if (!draft.hasSeatsForStudents) ...[
          const SizedBox(height: 4),
          Text(
            l10n.driverProposalNoSeats,
            style: VanepTypography.cardSubtitle.copyWith(
              fontSize: 12,
              color: VanepColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> showProposalVanSheet(
  BuildContext context, {
  required ProposalComposeDraft draft,
  required ValueChanged<String> onVanSelected,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showVanepSheet<void>(
    context,
    builder: (sheetContext) => VanepSheetFrame(
      title: l10n.driverProposalVanSheetTitle,
      child: Column(
        children: [
          for (final (index, van) in draft.vans.indexed) ...[
            if (index > 0) const Divider(),
            ProposalVanOptionTile(
              title: formatProposalVanName(l10n, van),
              subtitle: formatProposalVanSeats(l10n, draft.shift, van),
              isSelected: van.token == draft.selectedVanToken,
              onTap: () {
                onVanSelected(van.token);
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ],
      ),
    ),
  );
}

class ProposalVanOptionTile extends StatelessWidget {
  const ProposalVanOptionTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: VanepTypography.cardTitle),
                    Text(subtitle, style: VanepTypography.cardSubtitle),
                  ],
                ),
              ),
              VanepRadioIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}
