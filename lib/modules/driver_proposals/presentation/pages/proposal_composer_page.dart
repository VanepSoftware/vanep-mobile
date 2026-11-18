import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_composer_setup.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/driver_proposals_labels.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_composer_fields.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_cancellation_policy.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_draft.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/ui/vanep_schedule_editor.dart';

const proposalLatestEndWindow = Duration(days: 800);

class ProposalComposerActions {
  const ProposalComposerActions({required this.onRegisterVan});

  final Future<void> Function() onRegisterVan;
}

String? errorTextOf(
  AppLocalizations l10n,
  Set<ProposalDraftError> errors,
  List<ProposalDraftError> candidates,
) {
  for (final error in candidates) {
    if (errors.contains(error)) return proposalDraftErrorLabel(l10n, error);
  }
  return null;
}

class ProposalComposerPage extends StatelessWidget {
  const ProposalComposerPage({required this.actions, super.key});

  final ProposalComposerActions actions;

  void onStateChanged(BuildContext context, ProposalComposerState state) {
    final l10n = AppLocalizations.of(context)!;
    final failure = state.failure;
    if (state.sentProposal != null) {
      VanepFeedback.showInfo(context, l10n.proposalComposerSent);
      Navigator.of(context).pop(ProposalComposerOutcome.sent);
    } else if (failure != null && state.isReady) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
      if (isNegotiationOutdated(failure)) {
        Navigator.of(context).pop(ProposalComposerOutcome.outdated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposerCubit>();

    return BlocConsumer<ProposalComposerCubit, ProposalComposerState>(
      listenWhen: (previous, current) =>
          current.sentProposal != previous.sentProposal ||
          current.failure != previous.failure,
      listener: onStateChanged,
      builder: (context, state) {
        final setup = state.setup;
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: VanepAppBar(
            title: l10n.proposalComposerTitle,
            caption: setup == null
                ? null
                : formatClientAndChildren(l10n, setup.request),
          ),
          body: switch (state.status) {
            ProposalComposerStatus.ready when setup != null =>
              ProposalComposerBody(
                state: state,
                setup: setup,
                actions: actions,
              ),
            ProposalComposerStatus.loadFailed => VanepErrorView(
              message: l10n.proposalComposerLoadError,
              retryLabel: l10n.clientProposalsRetry,
              onRetry: cubit.load,
            ),
            _ => Center(
              child: CircularProgressIndicator(color: context.palette.action),
            ),
          },
          bottomNavigationBar: state.isReady
              ? ProposalComposerFooter(state: state)
              : null,
        );
      },
    );
  }
}

class ProposalComposerBody extends StatelessWidget {
  const ProposalComposerBody({
    required this.state,
    required this.setup,
    required this.actions,
    super.key,
  });

  final ProposalComposerState state;
  final ProposalComposerSetup setup;
  final ProposalComposerActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposerCubit>();
    final draft = setup.draft;
    final errors = state.visibleErrors;
    final names = {
      for (final item in setup.request.items)
        item.dependentToken: item.dependentFirstName,
    };
    final showsNames = draft.items.length > 1;
    final startsOn = draft.startsOn;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        DetailSection(
          title: l10n.proposalComposerValuesTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ComposerMoneyField(
                key: const ValueKey('total'),
                label: l10n.proposalComposerTotal,
                cents: draft.totalAmountCents,
                isRequired: true,
                errorText: errorTextOf(l10n, errors, const [
                  ProposalDraftError.totalBelowOneCentPerInstallment,
                ]),
                onChanged: cubit.changeTotalAmount,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ComposerNumberField(
                      key: const ValueKey('installments'),
                      label: l10n.negotiationAdjustmentFieldInstallments,
                      value: draft.installments,
                      errorText: errorTextOf(l10n, errors, const [
                        ProposalDraftError.installmentsOutOfRange,
                      ]),
                      onChanged: cubit.changeInstallments,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ComposerNumberField(
                      key: const ValueKey('due-day'),
                      label: l10n.proposalComposerDueDay,
                      value: draft.dueDay,
                      errorText: errorTextOf(l10n, errors, const [
                        ProposalDraftError.dueDayOutOfRange,
                      ]),
                      onChanged: cubit.changeDueDay,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: detailSectionSpacing),
        DetailSection(
          title: l10n.proposalDetailPeriod,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ComposerDateField(
                key: const ValueKey('starts-on'),
                label: l10n.proposalComposerStartsOn,
                date: startsOn,
                firstDate: state.today,
                lastDate: state.today.add(proposalLatestEndWindow),
                errorText: errorTextOf(l10n, errors, const [
                  ProposalDraftError.startDateInPast,
                ]),
                onPicked: cubit.changeStartsOn,
              ),
              const SizedBox(height: 12),
              ComposerDateField(
                key: const ValueKey('ends-on'),
                label: l10n.proposalComposerEndsOn,
                date: draft.endsOn,
                firstDate: startsOn ?? state.today,
                lastDate: state.today.add(proposalLatestEndWindow),
                errorText: errorTextOf(l10n, errors, const [
                  ProposalDraftError.endNotAfterStart,
                  ProposalDraftError.periodTooLong,
                ]),
                onPicked: cubit.changeEndsOn,
              ),
            ],
          ),
        ),
        const SizedBox(height: detailSectionSpacing),
        for (final item in draft.items) ...[
          ComposerItemSchedule(
            item: item,
            studentName: names[item.dependentToken] ?? '',
            showsStudentName: showsNames,
            missingLegError: item.hasAnyLeg
                ? null
                : errorTextOf(l10n, errors, const [
                    ProposalDraftError.studentWithoutLeg,
                  ]),
            onToggled: (leg, day) =>
                cubit.toggleLeg(item.dependentToken, leg, day),
            onTimePicked: (day, leg, time) =>
                cubit.changeTime(item.dependentToken, day, leg, time),
            onApplyToEveryDay: (leg, time) =>
                cubit.applyTimeToEveryDay(item.dependentToken, leg, time),
          ),
          const SizedBox(height: detailSectionSpacing),
        ],
        ComposerVanSection(
          setup: setup,
          onRegisterVan: () async {
            await actions.onRegisterVan();
            await cubit.refreshVans();
          },
        ),
        const SizedBox(height: detailSectionSpacing),
        ComposerConditionsSection(draft: draft),
        const SizedBox(height: detailSectionSpacing),
        ComposerValiditySection(draft: draft, errors: errors),
        const SizedBox(height: detailSectionSpacing),
        ComposerMessageField(message: draft.message),
      ],
    );
  }
}

class ComposerItemSchedule extends StatelessWidget {
  const ComposerItemSchedule({
    required this.item,
    required this.studentName,
    required this.showsStudentName,
    required this.missingLegError,
    required this.onToggled,
    required this.onTimePicked,
    required this.onApplyToEveryDay,
    super.key,
  });

  final ProposalDraftItem item;
  final String studentName;
  final bool showsStudentName;
  final String? missingLegError;
  final void Function(RouteLeg leg, Weekday day) onToggled;
  final void Function(Weekday day, RouteLeg leg, ClockTime time) onTimePicked;
  final void Function(RouteLeg leg, ClockTime time) onApplyToEveryDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepScheduleEditor(
      isAllowed: item.isRequested,
      isSelected: item.isEnabled,
      timeOf: item.timeOf,
      onToggled: onToggled,
      onTimePicked: onTimePicked,
      onApplyToEveryDay: onApplyToEveryDay,
      layoutBuilder: (days, times) {
        final daysBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.proposalComposerAsRequested,
              style: context.typography.cardSubtitle,
            ),
            const SizedBox(height: 8),
            days,
            if (missingLegError != null)
              ComposerFieldError(text: missingLegError!),
          ],
        );
        final timesBlock = times ?? const SizedBox.shrink();
        if (!showsStudentName) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetailSection(
                title: l10n.proposalDetailDaysTitle,
                child: daysBlock,
              ),
              const SizedBox(height: detailSectionSpacing),
              DetailSection(
                title: l10n.proposalDetailScheduleTitle,
                child: timesBlock,
              ),
            ],
          );
        }
        return DetailSection(
          title: studentName,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [daysBlock, const SizedBox(height: 12), timesBlock],
          ),
        );
      },
    );
  }
}

class ComposerVanSection extends StatelessWidget {
  const ComposerVanSection({
    required this.setup,
    required this.onRegisterVan,
    super.key,
  });

  final ProposalComposerSetup setup;
  final VoidCallback onRegisterVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposerCubit>();
    final selected = setup.draft.vehicleToken;
    return DetailSection(
      title: l10n.proposalComposerVanTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (setup.hasNoVan) ...[
            DetailNotice(
              icon: Icons.warning_amber_rounded,
              text: l10n.proposalComposerNoVan,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ProposalLinkButton(
                label: l10n.proposalComposerRegisterVan,
                showsChevron: true,
                onPressed: onRegisterVan,
              ),
            ),
          ] else if (setup.choosesVan) ...[
            if (selected == null)
              DetailNotice(text: l10n.proposalComposerChooseVan),
            for (final van in setup.vans)
              ProposalChoiceOption(
                label: formatDriverVan(l10n, van),
                isSelected: van.token == selected,
                onTap: () => cubit.chooseVehicle(van.token),
              ),
          ] else
            DetailNotice(
              icon: Icons.airport_shuttle_outlined,
              text: formatDriverVan(l10n, setup.vans.single),
            ),
        ],
      ),
    );
  }
}

class ComposerConditionsSection extends StatelessWidget {
  const ComposerConditionsSection({required this.draft, super.key});

  final ProposalDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposerCubit>();
    return DetailSection(
      title: l10n.proposalDetailConditionsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ComposerMoneyField(
            key: const ValueKey('enrollment-fee'),
            label: l10n.proposalDetailEnrollmentFee,
            hintText: l10n.proposalAdjustmentOptional,
            cents: draft.enrollmentFeeCents,
            onChanged: cubit.changeEnrollmentFee,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.proposalDetailAdjustment,
            style: context.typography.fieldLabel,
          ),
          for (final policy in ProposalAdjustmentPolicy.values)
            ProposalChoiceOption(
              label: adjustmentPolicyLabel(l10n, policy),
              isSelected: draft.adjustmentPolicy == policy,
              onTap: () => cubit.changeAdjustmentPolicy(policy),
            ),
          const SizedBox(height: 12),
          Text(
            l10n.proposalDetailCancellation,
            style: context.typography.fieldLabel,
          ),
          for (final policy in ProposalCancellationPolicy.values)
            ProposalChoiceOption(
              label: cancellationPolicyLabel(l10n, policy),
              isSelected: draft.cancellationPolicy == policy,
              onTap: () => cubit.changeCancellationPolicy(policy),
            ),
        ],
      ),
    );
  }
}

class ComposerValiditySection extends StatelessWidget {
  const ComposerValiditySection({
    required this.draft,
    required this.errors,
    super.key,
  });

  final ProposalDraft draft;
  final Set<ProposalDraftError> errors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposerCubit>();
    return DetailSection(
      title: l10n.proposalComposerValidityTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.proposalComposerValidityHint(proposalMaxValidDays),
            style: context.typography.cardSubtitle,
          ),
          const SizedBox(height: 12),
          ComposerNumberField(
            key: const ValueKey('valid-days'),
            label: l10n.proposalComposerValidDays,
            value: draft.validDays,
            errorText: errorTextOf(l10n, errors, const [
              ProposalDraftError.validDaysOutOfRange,
            ]),
            onChanged: cubit.changeValidDays,
          ),
        ],
      ),
    );
  }
}

class ComposerMessageField extends StatefulWidget {
  const ComposerMessageField({required this.message, super.key});

  final String message;

  @override
  State<ComposerMessageField> createState() => ComposerMessageFieldState();
}

class ComposerMessageFieldState extends State<ComposerMessageField> {
  late final controller = TextEditingController(text: widget.message);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepTextField(
      label: l10n.proposalAdjustmentMessage,
      controller: controller,
      hintText: l10n.proposalAdjustmentOptional,
      maxLength: proposalMessageMaxLength,
      minLines: 3,
      maxLines: 6,
      onChanged: context.read<ProposalComposerCubit>().changeMessage,
    );
  }
}

class ProposalComposerFooter extends StatelessWidget {
  const ProposalComposerFooter({required this.state, super.key});

  final ProposalComposerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProposalComposerCubit>();
    final preview = state.previewInstallmentCents;
    final installments = state.draft?.installments;
    final validDays = state.draft?.validDays ?? proposalMaxValidDays;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: context.palette.card,
          border: Border(top: BorderSide(color: context.palette.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (preview != null && installments != null)
              Center(
                child: VanepInstallmentPrice(
                  amountCents: preview,
                  installments: installments,
                  amountStyle: context.typography.heading.copyWith(
                    fontSize: 20,
                  ),
                  countStyle: context.typography.cardSubtitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              l10n.proposalComposerFooter(
                isWithin(validDays, 1, proposalMaxValidDays)
                    ? validDays
                    : proposalMaxValidDays,
              ),
              textAlign: TextAlign.center,
              style: context.typography.cardSubtitle,
            ),
            const SizedBox(height: 8),
            VanepPrimaryButton(
              label: l10n.proposalComposerSend,
              isLoading: state.isSending,
              onPressed: state.canSend ? cubit.send : null,
            ),
          ],
        ),
      ),
    );
  }
}
