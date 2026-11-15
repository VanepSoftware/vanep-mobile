import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/proposal_detail_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class ProposalAcceptedPage extends StatelessWidget {
  const ProposalAcceptedPage({
    required this.request,
    required this.proposal,
    super.key,
  });

  final ClientServiceRequest request;
  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final children = formatRequestChildren(l10n, request);
    final acceptedAt = proposal.acceptedAt;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: VanepAppBar(title: l10n.proposalAcceptedTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          VanepCard(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 32,
                  color: context.palette.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.proposalAcceptedContract(children, request.driverName),
                    style: context.typography.cardTitle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: detailSectionSpacing),
          DetailSection(
            title: l10n.proposalAcceptedSummaryTitle,
            child: Column(
              children: [
                DetailInfoRow(
                  label: l10n.proposalComparisonAmount,
                  values: [
                    formatInstallments(
                      l10n,
                      proposal.installments,
                      proposal.installmentAmountCents,
                    ),
                  ],
                ),
                DetailInfoRow(
                  label: l10n.proposalDetailPeriod,
                  values: [formatProposalPeriod(l10n, proposal)],
                ),
                DetailInfoRow(
                  label: l10n.proposalAcceptedDays,
                  values: [formatProposalDaysAndLegs(l10n, proposal)],
                ),
              ],
            ),
          ),
          const SizedBox(height: detailSectionSpacing),
          DetailSection(
            title: l10n.proposalAcceptedNextStepsTitle,
            child: Column(
              children: [
                AcceptedStep(
                  label: l10n.proposalAcceptedStepAccepted,
                  value: acceptedAt == null
                      ? null
                      : formatDayMonthAndTime(l10n, acceptedAt),
                  isDone: true,
                ),
                AcceptedStep(label: l10n.proposalAcceptedStepYourSignature),
                AcceptedStep(label: l10n.proposalAcceptedStepDriverSignature),
                AcceptedStep(
                  label: l10n.proposalAcceptedStepTripsStart,
                  value: formatCalendarDate(l10n, proposal.startsOn),
                ),
              ],
            ),
          ),
          const SizedBox(height: detailSectionSpacing),
          DetailNotice(text: l10n.proposalAcceptedOtherNegotiations(children)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VanepPrimaryButton(
                label: l10n.proposalAcceptedReviewAndSign,
                onPressed: () => openComingSoonPage(
                  context,
                  title: l10n.proposalAcceptedReviewAndSign,
                  message: l10n.comingSoon,
                ),
              ),
              const SizedBox(height: 8),
              VanepSecondaryButton(
                label: l10n.proposalAcceptedSignLater,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AcceptedStep extends StatelessWidget {
  const AcceptedStep({
    required this.label,
    this.value,
    this.isDone = false,
    super.key,
  });

  final String label;
  final String? value;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isDone ? context.palette.success : context.palette.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: context.typography.cardSubtitle.copyWith(
                color: context.palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (value != null)
            Text(value, style: context.typography.cardSubtitle),
        ],
      ),
    );
  }
}
