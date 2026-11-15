import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/core/ui/vanep_swipe_to_confirm.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/derive_assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_student_detail_page.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

class AssistantOnboardStudentsPage extends StatelessWidget {
  const AssistantOnboardStudentsPage({super.key});

  static Route<void> route(AssistantHomeCubit cubit) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantHomeCubit>.value(
        value: cubit,
        child: const AssistantOnboardStudentsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AssistantHomeCubit, AssistantHomeState>(
      listenWhen: (previous, current) =>
          previous.actionFailure != current.actionFailure,
      listener: showAssistantHomeFeedback,
      builder: (context, state) {
        final route = state.route;
        final link = selectAssistantVanLink(
          state.overview?.links ?? const [],
          state.selectedVanToken,
        );
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(
            backgroundColor: context.palette.surface,
            title: Text(l10n.assistantHomeOnBoardRowTitle),
          ),
          body: route == null
              ? const SizedBox.shrink()
              : AssistantOnboardStudentsBody(
                  route: route,
                  driverName: firstNameOf(link?.van.driverName ?? ''),
                ),
        );
      },
    );
  }
}

class AssistantOnboardStudentsBody extends StatelessWidget {
  const AssistantOnboardStudentsBody({
    required this.route,
    required this.driverName,
    super.key,
  });

  final AssistantRouteSnapshot route;
  final String driverName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final languageCode = Localizations.localeOf(context).languageCode;
    final leg = route.currentLeg ?? TripLeg.outbound;
    final groups = route.onboardGroupsOf(leg);
    final currentStop = route.currentStop;

    String stopLine(AssistantRoutePassenger passenger, {String? detail}) {
      final stop = route.boardingStopOf(passenger.token, leg);
      final parts = [
        if (stop != null) l10n.assistantOnboardStop(route.stopNumberOf(stop)),
        ?detail,
      ];
      return parts.join(vanSubtitleSeparator);
    }

    String? timeOf(DateTime? time) =>
        time == null ? null : formatClockTime(time, languageCode: languageCode);

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        if (currentStop != null)
          Text(
            l10n.assistantOnboardSubtitle(
              driverName,
              tripLegLabel(l10n, leg),
              stopKindTitle(l10n, currentStop.kind),
            ),
            style: context.typography.cardSubtitle,
          ),
        const SizedBox(height: assistantHomeItemSpacing),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            VanepChip(
              label: l10n.assistantHomeOnBoard(groups.onBoard.length),
              background: palette.successSurface,
              foreground: palette.success,
            ),
            VanepChip(
              label: l10n.assistantOnboardAwaitingCount(groups.awaiting.length),
              background: palette.actionSurface,
              foreground: palette.action,
            ),
            if (groups.didNotBoard.isNotEmpty)
              VanepChip(
                label: l10n.assistantOnboardNoShowCount(
                  groups.didNotBoard.length,
                ),
                background: palette.dangerSurface,
                foreground: palette.danger,
              ),
          ],
        ),
        const SizedBox(height: assistantHomeSectionSpacing),
        VanepSection(
          title: l10n.assistantOnboardSectionOnBoard,
          child: groups.onBoard.isEmpty
              ? Text(
                  l10n.assistantOnboardNobodyOnBoard,
                  style: context.typography.cardSubtitle,
                )
              : Column(
                  children: [
                    for (final passenger in groups.onBoard)
                      AssistantPassengerRow(
                        passenger: passenger,
                        onTap: () =>
                            openStudentDetail(context, route, passenger, leg),
                        subtitle: stopLine(
                          passenger,
                          detail: timeOf(passenger.confirmedAt),
                        ),
                        trailing: Icon(Icons.check, color: palette.success),
                      ),
                  ],
                ),
        ),
        if (groups.awaiting.isNotEmpty) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantOnboardSectionAwaiting,
            child: Column(
              children: [
                for (final passenger in groups.awaiting)
                  AssistantPassengerRow(
                    passenger: passenger,
                    onTap: () =>
                        openStudentDetail(context, route, passenger, leg),
                    subtitle: stopLine(passenger),
                    trailing: Text(
                      route.boardingStopOf(passenger.token, leg) == currentStop
                          ? l10n.assistantOnboardNow
                          : '~${timeOf(route.boardingStopOf(passenger.token, leg)?.plannedArrivalAt) ?? ''}',
                      style: context.typography.ratingLabel,
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (groups.didNotBoard.isNotEmpty) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantOnboardSectionNoShow,
            child: Column(
              children: [
                for (final passenger in groups.didNotBoard)
                  AssistantPassengerRow(
                    passenger: passenger,
                    onTap: () =>
                        openStudentDetail(context, route, passenger, leg),
                    subtitle: stopLine(
                      passenger,
                      detail: [
                        skipReasonText(l10n, passenger),
                        ?timeOf(passenger.confirmedAt),
                      ].join(vanSubtitleSeparator),
                    ),
                    trailing: TextButton(
                      onPressed: () => showCorrectionSheet(context, passenger),
                      child: Text(l10n.assistantOnboardCorrect),
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (groups.notGoingToday.isNotEmpty) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantHomeNotGoingToday,
            child: Column(
              children: [
                for (final passenger in groups.notGoingToday)
                  AssistantPassengerRow(
                    passenger: passenger,
                    onTap: () =>
                        openStudentDetail(context, route, passenger, leg),
                    subtitle: [
                      for (final absence in route.todayAbsences)
                        if (absence.passengerToken == passenger.token)
                          absenceNoticeLine(
                            l10n,
                            absence,
                            now: DateTime.now(),
                            languageCode: languageCode,
                          ),
                    ].firstOrNull,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> showCorrectionSheet(
    BuildContext context,
    AssistantRoutePassenger passenger,
  ) {
    final cubit = context.read<AssistantHomeCubit>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.card,
      builder: (sheetContext) => BlocProvider<AssistantHomeCubit>.value(
        value: cubit,
        child: AssistantCorrectionSheet(passenger: passenger),
      ),
    );
  }
}

class AssistantPassengerRow extends StatelessWidget {
  const AssistantPassengerRow({
    required this.passenger,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final AssistantRoutePassenger passenger;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final line = subtitle;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: VanepInitialAvatar(
        name: passenger.name,
        seed: passenger.token,
        size: 36,
      ),
      title: Text(passenger.name, style: context.typography.cardTitle),
      subtitle: line == null || line.isEmpty
          ? null
          : Text(line, style: context.typography.cardSubtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class AssistantCorrectionSheet extends StatelessWidget {
  const AssistantCorrectionSheet({required this.passenger, super.key});

  final AssistantRoutePassenger passenger;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AssistantHomeCubit, AssistantHomeState>(
      listenWhen: (previous, current) =>
          previous.isConfirming && !current.isConfirming,
      listener: (context, state) => Navigator.of(context).pop(),
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assistantOnboardCorrectTitle,
              style: context.typography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.assistantOnboardCorrectBody(firstNameOf(passenger.name)),
              style: context.typography.body,
            ),
            const SizedBox(height: assistantHomeSectionSpacing),
            VanepSwipeToConfirm(
              label: l10n.assistantConfirmBoarding,
              semanticsLabel: l10n.assistantOnboardCorrectSemantics(
                passenger.name,
              ),
              isLoading: state.isConfirming,
              onConfirmed: () => context
                  .read<AssistantHomeCubit>()
                  .correctNoShow(passenger.token),
            ),
          ],
        ),
      ),
    );
  }
}

void openStudentDetail(
  BuildContext context,
  AssistantRouteSnapshot route,
  AssistantRoutePassenger passenger,
  TripLeg leg,
) {
  final stop = route.boardingStopOf(passenger.token, leg);
  Navigator.of(context).push(
    AssistantStudentDetailPage.route(
      passenger.token,
      today: AssistantStudentToday(
        status: route.boardingStatusOf(passenger.token, leg),
        stopNumber: stop == null ? null : route.stopNumberOf(stop),
      ),
    ),
  );
}
