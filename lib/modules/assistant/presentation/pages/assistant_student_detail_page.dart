import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/phone/phone_caller.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_student_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/boarding_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_student_detail_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_boarding_history_page.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

const assistantSchoolWeekdays = [
  Weekday.monday,
  Weekday.tuesday,
  Weekday.wednesday,
  Weekday.thursday,
  Weekday.friday,
];

class AssistantStudentToday {
  const AssistantStudentToday({required this.status, this.stopNumber});

  final BoardingStatus status;
  final int? stopNumber;
}

class AssistantStudentDetailPage extends StatelessWidget {
  const AssistantStudentDetailPage({
    required this.studentToken,
    this.today,
    super.key,
  });

  final String studentToken;
  final AssistantStudentToday? today;

  static Route<void> route(
    String studentToken, {
    AssistantStudentToday? today,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantStudentDetailCubit>(
        create: (_) =>
            getIt<AssistantStudentDetailCubit>()..loadDetail(studentToken),
        child: AssistantStudentDetailPage(
          studentToken: studentToken,
          today: today,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<
      AssistantStudentDetailCubit,
      AssistantStudentDetailState
    >(
      builder: (context, state) => Scaffold(
        backgroundColor: context.palette.surface,
        appBar: AppBar(
          backgroundColor: context.palette.surface,
          title: Text(state.detail?.name ?? ''),
        ),
        body: switch (state.status) {
          AssistantStudentDetailStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          AssistantStudentDetailStatus.loadFailed => Padding(
            padding: assistantHomePagePadding,
            child: VanepErrorView(
              message: assistantFailureMessage(l10n, state.failure!),
              retryLabel: l10n.assistantHomeRetry,
              onRetry: () => context
                  .read<AssistantStudentDetailCubit>()
                  .loadDetail(studentToken),
            ),
          ),
          AssistantStudentDetailStatus.ready => AssistantStudentDetailBody(
            detail: state.detail!,
            today: today,
          ),
        },
      ),
    );
  }
}

String studentTodayLine(AppLocalizations l10n, AssistantStudentToday today) {
  final status = switch (today.status) {
    BoardingStatus.pending => l10n.assistantStudentTodayAwaiting,
    BoardingStatus.boarded => l10n.assistantStudentTodayOnBoard,
    BoardingStatus.droppedOff => l10n.assistantStudentTodayDroppedOff,
    BoardingStatus.noShow => l10n.assistantStudentTodayNoShow,
    BoardingStatus.notGoingToday => l10n.assistantStatusNotGoingToday,
  };
  return l10n.assistantStudentToday(status);
}

class AssistantStudentDetailBody extends StatelessWidget {
  const AssistantStudentDetailBody({
    required this.detail,
    this.today,
    super.key,
  });

  final AssistantStudentDetail detail;
  final AssistantStudentToday? today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;
    final languageCode = Localizations.localeOf(context).languageCode;
    String clock(DateTime time) =>
        formatClockTime(time, languageCode: languageCode);
    final windowStart = detail.pickupWindowStart;
    final windowEnd = detail.pickupWindowEnd;
    final returnAt = detail.returnDepartureAt;
    final note = detail.driverNote;
    final guardian = detail.visibleGuardian;
    final todayInfo = today;

    Widget infoRow(String title, String value, {String? detailLine}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: assistantHomeItemSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: typography.overline),
            Text(value, style: typography.cardTitle),
            if (detailLine != null)
              Text(detailLine, style: typography.cardSubtitle),
          ],
        ),
      );
    }

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        Row(
          children: [
            VanepInitialAvatar(name: detail.name, seed: detail.token, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(detail.name, style: typography.pageTitle),
                  Text(
                    [
                          detail.schoolName,
                          assistantVansShiftLabel(l10n, detail.shift),
                        ]
                        .where((part) => part.isNotEmpty)
                        .join(vanSubtitleSeparator),
                    style: typography.cardSubtitle,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (todayInfo != null) ...[
          const SizedBox(height: assistantHomeItemSpacing),
          VanepCard(
            highlighted: true,
            child: Row(
              children: [
                Icon(Icons.schedule, color: context.palette.action),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentTodayLine(l10n, todayInfo),
                        style: typography.cardTitle,
                      ),
                      if (todayInfo.stopNumber case final number?)
                        Text(
                          l10n.assistantOnboardStop(number),
                          style: typography.cardSubtitle,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: assistantHomeSectionSpacing),
        VanepSection(
          title: l10n.assistantStudentBoardingTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoRow(
                l10n.assistantStudentPickup,
                detail.pickupAddress,
                detailLine: windowStart != null && windowEnd != null
                    ? l10n.assistantStudentWindow(
                        clock(windowStart),
                        clock(windowEnd),
                      )
                    : null,
              ),
              infoRow(l10n.assistantStudentDropOff, detail.schoolName),
              if (returnAt != null)
                infoRow(
                  l10n.assistantStudentReturn,
                  l10n.assistantStudentReturnDeparture(clock(returnAt)),
                  detailLine: detail.returnsToPickupAddress
                      ? l10n.assistantStudentSameStop
                      : detail.returnAddress,
                ),
            ],
          ),
        ),
        const SizedBox(height: assistantHomeSectionSpacing),
        VanepSection(
          title: l10n.assistantStudentDaysTitle,
          child: VanepWeekLegsGrid<TripLeg>(
            rows: [
              for (final (leg, days) in [
                (TripLeg.outbound, detail.outboundDays),
                (TripLeg.inbound, detail.inboundDays),
              ])
                VanepWeekLegsRow(
                  leg: leg,
                  label: leg == TripLeg.outbound
                      ? l10n.assistantStopsOutbound
                      : l10n.assistantStopsReturn,
                  cells: {
                    for (final day in assistantSchoolWeekdays)
                      day: VanepWeekLegCell(isSelected: days.contains(day)),
                  },
                ),
            ],
          ),
        ),
        if (detail.siblings.isNotEmpty) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantStudentSiblingsTitle,
            child: Column(
              children: [
                for (final sibling in detail.siblings)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: VanepInitialAvatar(
                      name: sibling.name,
                      seed: sibling.token,
                      size: 36,
                    ),
                    title: Text(sibling.name, style: typography.cardTitle),
                    subtitle: Text(
                      [
                        sibling.relationship,
                        sibling.schoolName,
                      ].join(vanSubtitleSeparator),
                      style: typography.cardSubtitle,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context)
                        .push(AssistantStudentDetailPage.route(sibling.token)),
                  ),
              ],
            ),
          ),
        ],
        if (guardian != null) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantStudentGuardianTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: VanepInitialAvatar(
                name: guardian.name,
                seed: guardian.name,
                size: 36,
              ),
              title: Text(guardian.name, style: typography.cardTitle),
              subtitle: Text(
                guardian.relationship,
                style: typography.cardSubtitle,
              ),
              trailing: IconButton(
                tooltip: l10n.assistantHomeCallDriverNamed(
                  firstNameOf(guardian.name),
                ),
                onPressed: switch (guardian.phone) {
                  final phone? => () => getIt<PhoneCaller>().callPhone(phone),
                  null => null,
                },
                icon: const Icon(Icons.call),
              ),
            ),
          ),
        ],
        if (note != null && note.isNotEmpty) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantStudentDriverNoteTitle,
            child: Text(note, style: typography.body),
          ),
        ],
        const SizedBox(height: assistantHomeSectionSpacing),
        VanepCard(
          onTap: () => Navigator.of(context).push(
            AssistantBoardingHistoryPage.route(
              studentToken: detail.token,
              studentName: detail.name,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.history, color: context.palette.action),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.assistantHistoryTitle,
                      style: typography.cardTitle,
                    ),
                    Text(
                      l10n.assistantHistoryLastDays,
                      style: typography.cardSubtitle,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.palette.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}
