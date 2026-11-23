import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

enum ProposalSummaryTone { primary, muted, received }

class ProposalSummaryCard extends StatelessWidget {
  const ProposalSummaryCard({required this.draft, super.key});

  final ProposalComposeDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final installments = draft.payment.installments;
    return VanepRowsCard(
      rows: [
        ProposalSummaryLine(
          label: l10n.driverProposalFamilyTotal,
          total: formatMoney(l10n, draft.familyTotalCents),
          perInstallment: formatInstallmentAmount(
            l10n,
            installments: installments,
            monthlyCents: draft.monthlyFamilyCents,
          ),
          tone: ProposalSummaryTone.primary,
        ),
        ProposalSummaryLine(
          label: l10n.driverProposalCommission,
          total: formatMoney(l10n, draft.commissionTotalCents),
          perInstallment: formatInstallmentAmount(
            l10n,
            installments: installments,
            monthlyCents: draft.commissionCents,
          ),
          tone: ProposalSummaryTone.muted,
        ),
        ProposalSummaryLine(
          label: l10n.driverProposalReceived,
          total: formatMoney(l10n, draft.receivedTotalCents),
          perInstallment: formatInstallmentAmount(
            l10n,
            installments: installments,
            monthlyCents: draft.monthlyReceivedCents,
          ),
          tone: ProposalSummaryTone.received,
        ),
      ],
    );
  }
}

class ProposalSummaryLine extends StatelessWidget {
  const ProposalSummaryLine({
    required this.label,
    required this.total,
    required this.perInstallment,
    required this.tone,
    super.key,
  });

  final String label;
  final String total;
  final String perInstallment;
  final ProposalSummaryTone tone;

  @override
  Widget build(BuildContext context) {
    final labelStyle = switch (tone) {
      ProposalSummaryTone.primary => VanepTypography.body.copyWith(
        fontSize: 14,
      ),
      ProposalSummaryTone.muted => VanepTypography.cardSubtitle.copyWith(
        fontSize: 14,
      ),
      ProposalSummaryTone.received => VanepTypography.cardTitle.copyWith(
        fontSize: 14,
      ),
    };
    final totalStyle = switch (tone) {
      ProposalSummaryTone.primary => VanepTypography.cardTitle,
      ProposalSummaryTone.muted => VanepTypography.cardTitle.copyWith(
        color: VanepColors.textSecondary,
      ),
      ProposalSummaryTone.received => VanepTypography.cardTitle.copyWith(
        fontSize: 20,
        color: VanepColors.success,
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(total, style: totalStyle),
              Text(
                perInstallment,
                style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
