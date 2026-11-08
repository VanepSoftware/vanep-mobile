import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/money_input_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

class ProposalAdjustmentPage extends StatefulWidget {
  const ProposalAdjustmentPage({
    required this.request,
    required this.proposal,
    super.key,
  });

  final ClientServiceRequest request;
  final Proposal proposal;

  @override
  State<ProposalAdjustmentPage> createState() => ProposalAdjustmentPageState();
}

class ProposalAdjustmentPageState extends State<ProposalAdjustmentPage> {
  final suggestedValue = TextEditingController();
  final note = TextEditingController();

  @override
  void dispose() {
    suggestedValue.dispose();
    note.dispose();
    super.dispose();
  }

  void selectField(ProposalAdjustmentField field) {
    if (context.read<ProposalAdjustmentCubit>().state.draft.field != field) {
      suggestedValue.clear();
    }
    context.read<ProposalAdjustmentCubit>().selectField(field);
  }

  void changePrice(AppLocalizations l10n, String text) {
    final cents = parseMoneyInput(text);
    context.read<ProposalAdjustmentCubit>().changeSuggestedValue(
      cents == null ? '' : formatMoney(l10n, cents),
    );
  }

  void onStateChanged(BuildContext context, ProposalAdjustmentState state) {
    final l10n = AppLocalizations.of(context)!;
    final failure = state.failure;
    if (state.sentProposal != null) {
      VanepFeedback.showInfo(context, l10n.proposalAdjustmentSent);
      Navigator.of(context).pop(true);
    } else if (failure != null) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
      if (isNegotiationOutdated(failure)) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalAdjustmentCubit>();
    final proposal = widget.proposal;

    return BlocConsumer<ProposalAdjustmentCubit, ProposalAdjustmentState>(
      listenWhen: (previous, current) =>
          current.sentProposal != previous.sentProposal ||
          current.failure != previous.failure,
      listener: onStateChanged,
      builder: (context, state) {
        final field = state.draft.field;
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: VanepAppBar(title: l10n.proposalDetailAskAdjustment),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              VanepCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProposalDriverHeader(
                      request: widget.request,
                      subtitle: l10n.clientProposalsForChild(
                        formatRequestChildren(l10n, widget.request),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.proposalAdjustmentCurrentVersion(
                        proposal.version,
                        formatInstallments(
                          l10n,
                          proposal.installments,
                          proposal.installmentAmountCents,
                        ),
                      ),
                      style: VanepTypography.cardTitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: detailSectionSpacing),
              ProposalsSectionTitle(title: l10n.proposalAdjustmentChangesTitle),
              VanepCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    for (final option in ProposalAdjustmentField.values)
                      ProposalChoiceOption(
                        label: adjustmentFieldLabel(l10n, option),
                        isSelected: field == option,
                        onTap: () => selectField(option),
                      ),
                  ],
                ),
              ),
              if (field != null) ...[
                const SizedBox(height: detailSectionSpacing),
                if (field == ProposalAdjustmentField.price)
                  VanepTextField(
                    key: const ValueKey('adjustment-price'),
                    label: l10n.proposalAdjustmentPricePerInstallment,
                    controller: suggestedValue,
                    hintText: l10n.proposalAdjustmentOptional,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      MoneyInputFormatter(localeName: l10n.localeName),
                    ],
                    maxLength: adjustmentSuggestedValueMaxLength,
                    onChanged: (text) => changePrice(l10n, text),
                  )
                else
                  VanepTextField(
                    key: const ValueKey('adjustment-value'),
                    label: l10n.proposalAdjustmentSuggestedValue,
                    controller: suggestedValue,
                    hintText: l10n.proposalAdjustmentOptional,
                    maxLength: adjustmentSuggestedValueMaxLength,
                    onChanged: cubit.changeSuggestedValue,
                  ),
                const SizedBox(height: detailSectionSpacing),
                VanepTextField(
                  label: l10n.proposalAdjustmentMessage,
                  controller: note,
                  hintText: l10n.proposalAdjustmentOptional,
                  maxLength: adjustmentNoteMaxLength,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: cubit.changeNote,
                ),
              ],
              const SizedBox(height: detailSectionSpacing),
              DetailNotice(
                text: l10n.proposalAdjustmentValidUntil(
                  proposal.version,
                  formatDayAndMonth(l10n, proposal.validUntil),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: VanepPrimaryButton(
                label: l10n.proposalAdjustmentSend,
                isLoading: state.isSending,
                onPressed: state.canSend ? cubit.send : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
