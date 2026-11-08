import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/formatters/postal_address_display.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

const quoteStartDateWindow = Duration(days: 366);

const clientGapOrder = [
  ContractReadinessField.phone,
  ContractReadinessField.address,
  ContractReadinessField.document,
];

class QuoteRequestActions {
  const QuoteRequestActions({
    required this.onCompleteStudent,
    required this.onCompleteClientField,
    required this.onSent,
    required this.onOpenNegotiation,
  });

  final Future<void> Function(
    Dependent dependent,
    Set<ContractReadinessField> gaps,
  )
  onCompleteStudent;
  final Future<void> Function(ContractReadinessField field)
  onCompleteClientField;
  final void Function(ClientServiceRequest request) onSent;
  final void Function(ClientServiceRequest request) onOpenNegotiation;
}

String clientGapLabel(AppLocalizations l10n, ContractReadinessField field) {
  return switch (field) {
    ContractReadinessField.phone => l10n.quoteRequestGapPhone,
    ContractReadinessField.address => l10n.quoteRequestGapAddress,
    _ => l10n.quoteRequestGapDocument,
  };
}

bool canCompleteClientField(ContractReadinessField field) {
  return field == ContractReadinessField.phone ||
      field == ContractReadinessField.address;
}

List<VanepWeekLegsRow<RouteLeg>> weekLegsRowsOfDraft(
  AppLocalizations l10n,
  RequestDraftItem item,
) {
  return [
    for (final leg in RouteLeg.values)
      VanepWeekLegsRow(
        leg: leg,
        label: routeLegLabel(l10n, leg),
        cells: {
          for (final weekday in item.legsByDay.keys)
            weekday: VanepWeekLegCell(isSelected: item.hasLeg(weekday, leg)),
        },
      ),
  ];
}

Future<void> completeAndRefresh(
  BuildContext context,
  Future<void> Function() complete,
) async {
  final cubit = context.read<QuoteRequestCubit>();
  await complete();
  await cubit.refreshReadiness();
}

class QuoteRequestPage extends StatelessWidget {
  const QuoteRequestPage({required this.actions, super.key});

  final QuoteRequestActions actions;

  void onStateChanged(BuildContext context, QuoteRequestState state) {
    final l10n = AppLocalizations.of(context)!;
    final sent = state.sentRequest;
    final failure = state.failure;
    if (sent != null) {
      actions.onSent(sent);
    } else if (failure != null && state.existingNegotiation == null) {
      VanepFeedback.showError(
        context,
        negotiationFailureMessage(l10n, failure),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<QuoteRequestCubit>();

    return BlocConsumer<QuoteRequestCubit, QuoteRequestState>(
      listenWhen: (previous, current) =>
          current.sentRequest != previous.sentRequest ||
          current.failure != previous.failure,
      listener: onStateChanged,
      builder: (context, state) {
        final driver = state.driver;
        final draft = state.draft;
        return Scaffold(
          backgroundColor: VanepColors.surface,
          appBar: VanepAppBar(title: l10n.quoteRequestTitle),
          body: switch (state.status) {
            QuoteRequestStatus.ready when driver != null && draft != null =>
              QuoteRequestBody(
                state: state,
                driver: driver,
                draft: draft,
                actions: actions,
              ),
            QuoteRequestStatus.loadFailed => VanepErrorView(
              message: l10n.quoteRequestLoadError,
              retryLabel: l10n.clientProposalsRetry,
              onRetry: cubit.load,
            ),
            _ => const Center(
              child: CircularProgressIndicator(color: VanepColors.action),
            ),
          },
          bottomNavigationBar: state.status == QuoteRequestStatus.ready
              ? QuoteRequestFooter(state: state, actions: actions)
              : null,
        );
      },
    );
  }
}

class QuoteRequestBody extends StatelessWidget {
  const QuoteRequestBody({
    required this.state,
    required this.driver,
    required this.draft,
    required this.actions,
    super.key,
  });

  final QuoteRequestState state;
  final DriverProfile driver;
  final ServiceRequestDraft draft;
  final QuoteRequestActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = [
      for (final student in state.students)
        if (draft.isSelected(student.dependent.token)) student,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        QuoteDriverHeader(driver: driver),
        const SizedBox(height: detailSectionSpacing),
        DetailSection(
          title: l10n.quoteRequestStudentsTitle,
          child: state.students.isEmpty
              ? Text(
                  l10n.quoteRequestNoStudents,
                  style: VanepTypography.cardSubtitle,
                )
              : Column(
                  children: [
                    for (final student in state.students)
                      QuoteStudentOption(
                        student: student,
                        isSelected: draft.isSelected(student.dependent.token),
                        onComplete: () => completeAndRefresh(
                          context,
                          () => actions.onCompleteStudent(
                            student.dependent,
                            student.gaps,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        for (final item in draft.items) ...[
          const SizedBox(height: detailSectionSpacing),
          QuoteStudentLegs(
            item: item,
            name: state.studentWithToken(item.dependentToken)?.dependent.name,
          ),
        ],
        if (selected.isNotEmpty) ...[
          const SizedBox(height: detailSectionSpacing),
          QuoteRouteSection(students: selected),
        ],
        const SizedBox(height: detailSectionSpacing),
        QuoteStartDateField(date: draft.desiredStartDate, today: state.today!),
        const SizedBox(height: detailSectionSpacing),
        QuoteNotesField(notes: draft.notes),
      ],
    );
  }
}

class QuoteDriverHeader extends StatelessWidget {
  const QuoteDriverHeader({required this.driver, super.key});

  final DriverProfile driver;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rating = driver.rating;
    final van = driver.vehicles.isEmpty ? null : driver.vehicles.first;
    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalPersonHeader(
            avatar: VanepPersonAvatar(name: driver.name),
            name: driver.name,
            subtitle: rating == null
                ? null
                : formatProposalRating(l10n, rating),
            subtitleLeading: rating == null
                ? null
                : const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: VanepColors.ratingStar,
                  ),
          ),
          if (van != null) ...[
            const SizedBox(height: 10),
            DetailNotice(
              icon: Icons.airport_shuttle_outlined,
              text: l10n.negotiationVehicle(
                van.model,
                van.manufactureYear,
                van.capacity,
              ),
            ),
          ],
          if (!driver.available) ...[
            const SizedBox(height: 10),
            DetailNotice(text: l10n.quoteRequestDriverUnavailable),
          ],
        ],
      ),
    );
  }
}

class QuoteStudentOption extends StatelessWidget {
  const QuoteStudentOption({
    required this.student,
    required this.isSelected,
    required this.onComplete,
    super.key,
  });

  final QuoteStudent student;
  final bool isSelected;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<QuoteRequestCubit>();
    final dependent = student.dependent;
    final isReady = student.isReady;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            checked: isSelected,
            enabled: isReady,
            child: InkWell(
              onTap: isReady
                  ? () => cubit.toggleStudent(dependent.token)
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Checkbox(
                        value: isSelected,
                        onChanged: isReady
                            ? (_) => cubit.toggleStudent(dependent.token)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dependent.name,
                            style: VanepTypography.cardTitle.copyWith(
                              color: isReady
                                  ? VanepColors.textPrimary
                                  : VanepColors.textMuted,
                            ),
                          ),
                          if (!isReady)
                            Text(
                              l10n.quoteRequestIncomplete,
                              style: VanepTypography.cardSubtitle.copyWith(
                                color: VanepColors.warning,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!isReady)
          ProposalLinkButton(
            label: l10n.quoteRequestComplete,
            onPressed: onComplete,
          ),
      ],
    );
  }
}

class QuoteStudentLegs extends StatelessWidget {
  const QuoteStudentLegs({required this.item, this.name, super.key});

  final RequestDraftItem item;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<QuoteRequestCubit>();
    final name = this.name;
    return DetailSection(
      title: name == null
          ? l10n.proposalDetailDaysTitle
          : '${l10n.proposalDetailDaysTitle} · ${joinFirstNames(l10n, [name])}',
      child: VanepWeekLegsGrid<RouteLeg>(
        rows: weekLegsRowsOfDraft(l10n, item),
        onToggled: (leg, weekday) =>
            cubit.toggleLeg(item.dependentToken, weekday, leg),
      ),
    );
  }
}

class QuoteRouteSection extends StatelessWidget {
  const QuoteRouteSection({required this.students, super.key});

  final List<QuoteStudent> students;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showsNames = students.length > 1;
    return DetailSection(
      title: l10n.quoteRequestRouteTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, student) in students.indexed) ...[
            if (index > 0) const SizedBox(height: 20),
            if (showsNames)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  joinFirstNames(l10n, [student.dependent.name]),
                  style: VanepTypography.fieldLabel,
                ),
              ),
            ...buildStops(l10n, student.dependent),
          ],
        ],
      ),
    );
  }

  List<Widget> buildStops(AppLocalizations l10n, Dependent dependent) {
    final pickup = dependent.address;
    final school = dependent.school;
    return [
      if (pickup != null)
        QuoteRouteStop(
          icon: Icons.home_outlined,
          label: l10n.quoteRequestPickup,
          title: displayAddress(pickup).street,
          details: displayAddress(pickup).details,
          isLast: school == null,
        ),
      if (school != null)
        QuoteRouteStop(
          icon: Icons.school_outlined,
          label: l10n.quoteRequestDestination,
          title: school.name,
          details: switch (school.address) {
            final address? => displayAddress(address).details,
            null => '',
          },
          isLast: true,
        ),
    ];
  }

  PostalAddressDisplayFields displayAddress(DependentAddress address) {
    return postalAddressDisplayFields(
      street: address.street,
      number: address.number,
      complement: address.complement,
      neighborhood: address.neighborhood,
      cityName: address.cityName,
      uf: address.stateUf,
    );
  }
}

class QuoteRouteStop extends StatelessWidget {
  const QuoteRouteStop({
    required this.icon,
    required this.label,
    required this.title,
    required this.details,
    required this.isLast,
    super.key,
  });

  final IconData icon;
  final String label;
  final String title;
  final String details;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: VanepColors.actionSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: VanepColors.action),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: VanepColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: VanepColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(title, style: VanepTypography.fieldLabel),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(details, style: VanepTypography.cardSubtitle),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuoteStartDateField extends StatefulWidget {
  const QuoteStartDateField({
    required this.date,
    required this.today,
    super.key,
  });

  final DateTime? date;
  final DateTime today;

  @override
  State<QuoteStartDateField> createState() => QuoteStartDateFieldState();
}

class QuoteStartDateFieldState extends State<QuoteStartDateField> {
  final controller = TextEditingController();

  void showDate() {
    final date = widget.date;
    controller.text = date == null
        ? ''
        : formatNumericDate(AppLocalizations.of(context)!, date);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showDate();
  }

  @override
  void didUpdateWidget(QuoteStartDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) showDate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final cubit = context.read<QuoteRequestCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.date ?? widget.today,
      firstDate: widget.today,
      lastDate: widget.today.add(quoteStartDateWindow),
    );
    if (picked != null) cubit.changeStartDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepTextField(
      label: l10n.proposalDetailDesiredStart,
      controller: controller,
      isRequired: true,
      readOnly: true,
      onTap: pickDate,
      onChanged: (_) {},
      suffix: const Icon(Icons.calendar_today_outlined),
    );
  }
}

class QuoteNotesField extends StatefulWidget {
  const QuoteNotesField({required this.notes, super.key});

  final String notes;

  @override
  State<QuoteNotesField> createState() => QuoteNotesFieldState();
}

class QuoteNotesFieldState extends State<QuoteNotesField> {
  late final controller = TextEditingController(text: widget.notes);

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
      maxLength: serviceRequestNotesMaxLength,
      minLines: 3,
      maxLines: 6,
      onChanged: context.read<QuoteRequestCubit>().changeNotes,
    );
  }
}

class QuoteRequestFooter extends StatelessWidget {
  const QuoteRequestFooter({
    required this.state,
    required this.actions,
    super.key,
  });

  final QuoteRequestState state;
  final QuoteRequestActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<QuoteRequestCubit>();
    final existing = state.existingNegotiation;
    final failure = state.failure;
    final clientGaps = [
      for (final field in clientGapOrder)
        if (state.clientGaps.contains(field)) field,
    ];

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: VanepColors.card,
          border: Border(top: BorderSide(color: VanepColors.divider)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (existing != null && failure != null) ...[
              DetailNotice(text: negotiationFailureMessage(l10n, failure)),
              Align(
                alignment: Alignment.centerLeft,
                child: ProposalLinkButton(
                  label: l10n.quoteRequestSeeNegotiation,
                  showsChevron: true,
                  onPressed: () => actions.onOpenNegotiation(existing),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (clientGaps.isNotEmpty) ...[
              DetailNotice(
                icon: Icons.warning_amber_rounded,
                text: l10n.quoteRequestClientGapsTitle,
              ),
              Wrap(
                spacing: 12,
                children: [
                  for (final field in clientGaps)
                    canCompleteClientField(field)
                        ? ProposalLinkButton(
                            label: clientGapLabel(l10n, field),
                            onPressed: () => completeAndRefresh(
                              context,
                              () => actions.onCompleteClientField(field),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              clientGapLabel(l10n, field),
                              style: VanepTypography.cardSubtitle.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Text(
              state.hasReachedLimit
                  ? l10n.quoteRequestLimitReached(openRequestsLimit)
                  : l10n.quoteRequestFooter,
              textAlign: TextAlign.center,
              style: VanepTypography.cardSubtitle.copyWith(
                color: state.hasReachedLimit
                    ? VanepColors.warning
                    : VanepColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            VanepPrimaryButton(
              label: l10n.quoteRequestSend,
              isLoading: state.isSending,
              onPressed: state.canSend ? cubit.send : null,
            ),
          ],
        ),
      ),
    );
  }
}
