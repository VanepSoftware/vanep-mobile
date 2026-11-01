import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_decline_reason.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/proposal_detail_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_choice_option.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_confirmations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_detail_sections.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/decline_reason.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

class ProposalDeclineSheet extends StatefulWidget {
  const ProposalDeclineSheet({
    required this.request,
    required this.proposal,
    super.key,
  });

  final ClientServiceRequest request;
  final Proposal proposal;

  @override
  State<ProposalDeclineSheet> createState() => ProposalDeclineSheetState();
}

class ProposalDeclineSheetState extends State<ProposalDeclineSheet> {
  final message = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  void onStateChanged(BuildContext context, ProposalDeclineState state) {
    final l10n = AppLocalizations.of(context)!;
    final failure = state.failure;
    if (state.declinedProposal != null) {
      Navigator.of(context).pop(ProposalDeclineOutcome.declined);
    } else if (failure != null) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
      if (isNegotiationOutdated(failure)) {
        Navigator.of(context).pop(ProposalDeclineOutcome.outdated);
      }
    }
  }

  Future<void> sendAfterConfirming(
    BuildContext context,
    String reasonLabel,
  ) async {
    final cubit = context.read<ProposalDeclineCubit>();
    if (await confirmProposalDecline(context, widget.request)) {
      await cubit.send(reasonLabel: reasonLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalDeclineCubit>();
    final proposal = widget.proposal;
    final request = widget.request;

    return BlocConsumer<ProposalDeclineCubit, ProposalDeclineState>(
      listenWhen: (previous, current) =>
          current.declinedProposal != previous.declinedProposal ||
          current.failure != previous.failure,
      listener: onStateChanged,
      builder: (context, state) {
        final reason = state.reason;
        final reasonLabel = reason == null
            ? null
            : declineReasonLabel(l10n, reason);
        final messageMaxLength = declineMessageMaxLength([
          for (final option in ProposalDeclineReason.values)
            declineReasonLabel(l10n, option),
        ]);
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.proposalDeclineTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: VanepColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ProposalDriverHeader(
                  request: request,
                  subtitle: l10n.proposalDeclineSummary(
                    formatInstallments(
                      l10n,
                      proposal.installments,
                      proposal.installmentAmountCents,
                    ),
                    formatRequestChildren(l10n, request),
                  ),
                ),
                const SizedBox(height: detailSectionSpacing),
                Text(
                  l10n.proposalDeclineReasonTitle,
                  style: VanepTypography.sectionTitle,
                ),
                for (final option in ProposalDeclineReason.values)
                  ProposalChoiceOption(
                    label: declineReasonLabel(l10n, option),
                    isSelected: reason == option,
                    onTap: () => cubit.selectReason(option),
                  ),
                if (reasonLabel != null) ...[
                  const SizedBox(height: 8),
                  VanepTextField(
                    label: l10n.proposalAdjustmentMessage,
                    controller: message,
                    hintText: l10n.proposalAdjustmentOptional,
                    maxLength: messageMaxLength,
                    minLines: 2,
                    maxLines: 4,
                    onChanged: cubit.changeMessage,
                  ),
                ],
                const SizedBox(height: detailSectionSpacing),
                DetailNotice(
                  text: l10n.proposalDeclineClosesNegotiation(
                    request.driverName,
                  ),
                ),
                const SizedBox(height: detailSectionSpacing),
                VanepPrimaryButton(
                  label: l10n.proposalDeclineTitle,
                  isLoading: state.isSending,
                  onPressed: reasonLabel != null && state.canSend
                      ? () => sendAfterConfirming(context, reasonLabel)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
