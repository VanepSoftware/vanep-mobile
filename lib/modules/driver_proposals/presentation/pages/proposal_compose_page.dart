import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_rows_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_compose_parts.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_conditions_section.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_payment_section.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_price_section.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_rows.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_schedule_grid.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_summary_card.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_times_section.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_van_section.dart';

class ProposalComposePage extends StatelessWidget {
  const ProposalComposePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposeCubit>();

    return BlocConsumer<ProposalComposeCubit, ProposalComposeState>(
      listenWhen: proposalComposeShouldNotify,
      listener: notifyProposalCompose,
      builder: (context, state) {
        final draft = editableProposalDraft(state);
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: VanepAppBar(
            title: l10n.driverProposalComposeTitle,
            subtitle: draft == null
                ? null
                : formatProposalHeaderSubtitle(l10n, draft),
          ),
          body: RefreshIndicator(
            onRefresh: cubit.loadDraft,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: proposalComposeChildren(context, state, cubit),
            ),
          ),
          bottomNavigationBar: draft == null
              ? null
              : ProposalSendBar(
                  draft: draft,
                  isSending: state.status == ProposalComposeStatus.sending,
                  onSend: canSendProposal(state) ? cubit.sendProposal : null,
                ),
        );
      },
    );
  }
}

ProposalComposeDraft? editableProposalDraft(ProposalComposeState state) {
  final draft = state.draft;
  if (draft == null) return null;
  if (draft.block == ProposalComposeBlock.notAcceptingStudents) return null;
  return draft;
}

bool canSendProposal(ProposalComposeState state) {
  final draft = state.draft;
  return draft != null &&
      draft.canSend &&
      state.status == ProposalComposeStatus.ready;
}

bool proposalComposeShouldNotify(
  ProposalComposeState previous,
  ProposalComposeState current,
) {
  if (current.status == ProposalComposeStatus.sent &&
      previous.status != ProposalComposeStatus.sent) {
    return true;
  }
  return current.status == ProposalComposeStatus.ready &&
      current.failure != null &&
      previous.failure != current.failure;
}

void notifyProposalCompose(BuildContext context, ProposalComposeState state) {
  final l10n = AppLocalizations.of(context)!;
  if (state.status == ProposalComposeStatus.sent) {
    VanepFeedback.showInfo(context, l10n.driverProposalSent);
    return;
  }
  final failure = state.failure;
  if (failure == null) return;
  VanepFeedback.showError(context, driverProposalFailureLabel(l10n, failure));
}

List<Widget> proposalComposeChildren(
  BuildContext context,
  ProposalComposeState state,
  ProposalComposeCubit cubit,
) {
  final l10n = AppLocalizations.of(context)!;
  final draft = state.draft;
  if (draft == null) {
    if (state.status == ProposalComposeStatus.loadFailed) {
      return [
        VanepErrorView(
          message: l10n.driverProposalLoadError,
          retryLabel: l10n.driverProposalRetry,
          onRetry: cubit.loadDraft,
        ),
      ];
    }
    return const [ProposalComposeSkeleton()];
  }

  if (draft.block == ProposalComposeBlock.notAcceptingStudents) {
    return [
      ProposalComposeNotice(
        title: l10n.driverProposalNotAcceptingTitle,
        message: l10n.driverProposalNotAcceptingMessage,
      ),
    ];
  }

  final editable = state.status != ProposalComposeStatus.sending;

  return withSpacing([
    if (draft.block == ProposalComposeBlock.overdueInvoice)
      ProposalComposeNotice(
        title: l10n.driverProposalOverdueTitle,
        message: l10n.driverProposalOverdueMessage,
      ),
    ProposalVanSection(
      draft: draft,
      onVanSelected: editable ? cubit.selectVan : null,
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepSectionHeader(title: l10n.driverProposalPriceSection),
        StudentPriceEditor(
          students: draft.students,
          legsLabel: formatProposalLegs(l10n, draft.legs),
          onPriceChanged: editable ? cubit.changeStudentPrice : null,
        ),
        const SizedBox(height: 12),
        ProposalSummaryCard(draft: draft),
      ],
    ),
    ProposalPaymentSection(
      payment: draft.payment,
      onPaymentChanged: editable ? cubit.changePayment : null,
    ),
    ProposalScheduleSection(
      draft: draft,
      onSlotToggled: editable ? cubit.toggleSlot : null,
    ),
    ProposalTimesSection(
      times: draft.times,
      onTimesChanged: editable ? cubit.changeTimes : null,
    ),
    ProposalConditionsSection(
      conditions: draft.conditions,
      onConditionsChanged: editable ? cubit.changeConditions : null,
    ),
    ProposalMessageSection(
      message: draft.message,
      onMessageChanged: editable ? cubit.changeMessage : null,
    ),
    ProposalValidityNote(days: draft.validityDays),
  ], proposalSectionSpacing);
}
