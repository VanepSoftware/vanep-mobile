import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_read_only_field.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/proposal_compose_labels.dart';

class ProposalComposePage extends StatelessWidget {
  const ProposalComposePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProposalComposeCubit>();

    return SafeArea(
      bottom: false,
      child: BlocConsumer<ProposalComposeCubit, ProposalComposeState>(
        listenWhen: proposalComposeShouldNotify,
        listener: notifyProposalCompose,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: cubit.loadDraft,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: proposalComposeChildren(context, state, cubit),
            ),
          );
        },
      ),
    );
  }
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
      Text(l10n.driverProposalComposeTitle, style: VanepTypography.pageTitle),
      const SizedBox(height: 20),
      ProposalComposeNotice(
        title: l10n.driverProposalNotAcceptingTitle,
        message: l10n.driverProposalNotAcceptingMessage,
      ),
    ];
  }

  final canSend = draft.canSend && state.status == ProposalComposeStatus.ready;

  return [
    Text(l10n.driverProposalComposeTitle, style: VanepTypography.pageTitle),
    const SizedBox(height: 8),
    Text(l10n.driverProposalOneContract, style: VanepTypography.cardSubtitle),
    if (draft.block == ProposalComposeBlock.overdueInvoice) ...[
      const SizedBox(height: 16),
      ProposalComposeNotice(
        title: l10n.driverProposalOverdueTitle,
        message: l10n.driverProposalOverdueMessage,
      ),
    ],
    const SizedBox(height: 20),
    ProposalComposeSectionTitle(title: l10n.driverProposalFamilySection),
    VanepCard(
      child: Text(draft.familyName, style: VanepTypography.cardTitle),
    ),
    const SizedBox(height: 20),
    ProposalComposeSectionTitle(title: l10n.driverProposalPriceSection),
    StudentPriceEditor(
      students: draft.students,
      onPriceChanged: cubit.changeStudentPrice,
    ),
    const SizedBox(height: 8),
    ProposalComposeSectionTitle(
      title: l10n.driverProposalScheduleSection,
      subtitle: l10n.driverProposalScheduleHint,
    ),
    ProposalScheduleList(days: groupProposalSchedule(draft.schedule)),
    const SizedBox(height: 8),
    ProposalComposeSectionTitle(title: l10n.driverProposalConditionsSection),
    ProposalConditionsFields(conditions: draft.conditions),
    const SizedBox(height: 20),
    ProposalComposeSectionTitle(title: l10n.driverProposalMoneySection),
    ProposalMoneyCard(draft: draft),
    const SizedBox(height: 20),
    VanepPrimaryButton(
      label: l10n.driverProposalSend,
      isLoading: state.status == ProposalComposeStatus.sending,
      onPressed: canSend ? cubit.sendProposal : null,
    ),
  ];
}

class ProposalComposeSkeleton extends StatelessWidget {
  const ProposalComposeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(words: 2, fontSize: 26),
          SizedBox(height: 16),
          VanepCard(child: Bone(height: 72, width: double.infinity)),
          SizedBox(height: 16),
          VanepCard(child: Bone(height: 120, width: double.infinity)),
        ],
      ),
    );
  }
}

class ProposalComposeNotice extends StatelessWidget {
  const ProposalComposeNotice({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VanepColors.warningSurface,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        border: Border.all(color: VanepColors.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VanepTypography.cardTitle),
          const SizedBox(height: 4),
          Text(message, style: VanepTypography.body),
        ],
      ),
    );
  }
}

class ProposalComposeSectionTitle extends StatelessWidget {
  const ProposalComposeSectionTitle({
    required this.title,
    this.subtitle,
    super.key,
  });

  final String title;

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VanepTypography.sectionTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: VanepTypography.cardSubtitle),
          ],
        ],
      ),
    );
  }
}

class ProposalScheduleList extends StatelessWidget {
  const ProposalScheduleList({required this.days, super.key});

  final List<ProposalScheduleDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        for (final day in days) ...[
          VanepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatProposalWeekday(l10n, day.weekday),
                  style: VanepTypography.cardTitle,
                ),
                const SizedBox(height: 8),
                for (final slot in day.slots)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text(
                          formatRouteLeg(l10n, slot.leg),
                          style: VanepTypography.cardSubtitle,
                        ),
                        const Spacer(),
                        Text(
                          formatProposalClock(l10n, slot.minutesFromMidnight),
                          style: VanepTypography.cardTitle,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class ProposalConditionsFields extends StatelessWidget {
  const ProposalConditionsFields({required this.conditions, super.key});

  final ProposalConditions conditions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        VanepReadOnlyField(
          label: l10n.driverProposalDueDayLabel,
          value: l10n.driverProposalDueDayValue(conditions.dueDay),
        ),
        const SizedBox(height: 12),
        VanepReadOnlyField(
          label: l10n.driverProposalNotesLabel,
          value: conditions.notes,
        ),
      ],
    );
  }
}

class ProposalMoneyCard extends StatelessWidget {
  const ProposalMoneyCard({required this.draft, super.key});

  final ProposalComposeDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          ProposalMoneyLine(
            label: l10n.driverProposalFamilyPays,
            amount: formatMoney(l10n, draft.familyAmountCents),
          ),
          const SizedBox(height: 8),
          ProposalMoneyLine(
            label: l10n.driverProposalCommission,
            amount: formatMoney(l10n, draft.commissionCents),
          ),
          const SizedBox(height: 8),
          ProposalMoneyLine(
            label: l10n.driverProposalReceived,
            amount: formatMoney(l10n, draft.receivedCents),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class ProposalMoneyLine extends StatelessWidget {
  const ProposalMoneyLine({
    required this.label,
    required this.amount,
    this.emphasized = false,
    super.key,
  });

  final String label;

  final String amount;

  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? VanepTypography.cardTitle
        : VanepTypography.cardSubtitle;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(amount, style: VanepTypography.cardTitle),
      ],
    );
  }
}

class StudentPriceEditor extends StatefulWidget {
  const StudentPriceEditor({
    required this.students,
    required this.onPriceChanged,
    super.key,
  });

  final List<ProposalStudentLine> students;

  final void Function(String token, int cents) onPriceChanged;

  @override
  State<StudentPriceEditor> createState() => StudentPriceEditorState();
}

class StudentPriceEditorState extends State<StudentPriceEditor> {
  final controllers = <String, TextEditingController>{};

  @override
  void didUpdateWidget(StudentPriceEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final student in widget.students) {
      final controller = controllers[student.token];
      if (controller == null) continue;
      if (parseReaisInput(controller.text) == student.monthlyAmountCents) {
        continue;
      }
      final text = formatReaisInput(student.monthlyAmountCents);
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        for (final student in widget.students) ...[
          VanepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: VanepTypography.cardTitle),
                const SizedBox(height: 2),
                Text(student.schoolName, style: VanepTypography.cardSubtitle),
                const SizedBox(height: 12),
                VanepTextField(
                  label: l10n.driverProposalPriceLabel,
                  controller: controllerFor(student),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const [ReaisInputFormatter()],
                  onChanged: (text) => reportStudentPrice(
                    student: student,
                    text: text,
                    onPriceChanged: widget.onPriceChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  TextEditingController controllerFor(ProposalStudentLine student) {
    final existing = controllers[student.token];
    if (existing != null) return existing;
    final created = TextEditingController(
      text: formatReaisInput(student.monthlyAmountCents),
    );
    controllers[student.token] = created;
    return created;
  }
}
