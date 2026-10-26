import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/school_shift_label.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';

String vanTitle(AppLocalizations l10n, VanDay van) {
  return l10n.clientHomeVanTitle(van.driverName, formatShift(l10n, van.shift));
}

List<String> riderNames(VanDay van) =>
    van.riders.map((rider) => rider.name).toList();

class VanDayCard extends StatelessWidget {
  const VanDayCard({required this.van, super.key});

  final VanDay van;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stopChange = van.stopChange;

    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VanepAvatarStack(
                names: riderNames(van),
                dimmedNames: {for (final rider in van.absentRiders) rider.name},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vanTitle(l10n, van), style: VanepTypography.cardTitle),
                    Text(
                      l10n.clientHomeVanSubtitle(
                        van.vehicleModel,
                        van.plate,
                        formatTimeOfDay(l10n, van.departureAt),
                      ),
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: VanepColors.divider),
          VanScheduleRow(schedule: van.schedule),
          const Divider(height: 28, color: VanepColors.divider),
          for (final rider in van.absentRiders)
            VanNoticeRow(
              icon: Icons.event_busy_outlined,
              iconColor: VanepColors.warning,
              text: l10n.clientHomeNotGoingToday(rider.name),
              actionLabel: l10n.clientHomeUndo,
              onAction: () => openUnavailableFeature(
                context,
                l10n.clientHomeShortcutReportAbsence,
              ),
            ),
          if (stopChange != null)
            VanNoticeRow(
              icon: Icons.edit_location_alt_outlined,
              iconColor: VanepColors.action,
              text: formatStopChange(l10n, stopChange),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientHomeNotGoingTodayAction,
                  icon: Icons.event_busy_outlined,
                  onPressed: () => openUnavailableFeature(
                    context,
                    l10n.clientHomeShortcutReportAbsence,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientHomeTalkTo(van.driverName),
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => openUnavailableFeature(
                    context,
                    l10n.clientHomeTalkTo(van.driverName),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VanScheduleRow extends StatelessWidget {
  const VanScheduleRow({required this.schedule, super.key});

  final VanSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ScheduleCell(
            label: l10n.clientHomeBoarding,
            value: formatTimeWindow(
              l10n,
              schedule.boardingStartAt,
              schedule.boardingEndAt,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ScheduleCell(
            label: l10n.clientHomeArrival,
            value: formatTimeOfDay(l10n, schedule.schoolArrivalAt),
          ),
        ),
        Expanded(
          flex: 3,
          child: ScheduleCell(
            label: l10n.clientHomeDeparture,
            value: formatTimeOfDay(l10n, schedule.schoolDepartureAt),
          ),
        ),
      ],
    );
  }
}

class ScheduleCell extends StatelessWidget {
  const ScheduleCell({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: VanepTypography.cardSubtitle),
        const SizedBox(height: 2),
        Text(value, style: VanepTypography.cardTitle),
      ],
    );
  }
}

class VanNoticeRow extends StatelessWidget {
  const VanNoticeRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: VanepTypography.body)),
          if (label != null)
            TextButton(
              onPressed: onAction,
              child: Text(label, style: VanepTypography.linkAction),
            ),
        ],
      ),
    );
  }
}

class VanDayRow extends StatelessWidget {
  const VanDayRow({required this.van, super.key});

  final VanDay van;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final names = van.presentRiders.map((rider) => rider.name).toList();
    return HomeRowsCard(
      rows: [
        HomeRowTile(
          leading: names.length == 1
              ? VanepPersonAvatar(name: names.single)
              : VanepAvatarStack(names: names),
          title: vanTitle(l10n, van),
          subtitle: l10n.clientHomeVanRowSubtitle(
            joinNames(l10n, names),
            formatTimeOfDay(l10n, van.schedule.boardingStartAt),
          ),
          onTap: () => openUnavailableFeature(context, vanTitle(l10n, van)),
        ),
      ],
    );
  }
}

String noRouteReasonSentence(AppLocalizations l10n, ChildWithoutRoute child) {
  return switch (child.reason) {
    NoRouteReason.goesWithGuardian => l10n.clientHomeGoesWithGuardian(
      child.name,
    ),
    NoRouteReason.noVanYet => l10n.clientHomeStillWithoutVan(child.name),
  };
}

String noRouteReasonForSingleChild(
  AppLocalizations l10n,
  ChildWithoutRoute child,
) {
  return switch (child.reason) {
    NoRouteReason.goesWithGuardian => l10n.clientHomeGoesWithGuardianSingle,
    NoRouteReason.noVanYet => l10n.clientHomeStillWithoutVanSingle,
  };
}

class ChildrenWithoutRouteRow extends StatelessWidget {
  const ChildrenWithoutRouteRow({required this.children, super.key});

  final List<ChildWithoutRoute> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final names = children.map((child) => child.name).toList();
    final single = children.length == 1 ? children.single : null;

    return HomeRowsCard(
      rows: [
        HomeRowTile(
          leading: single != null
              ? VanepPersonAvatar(name: single.name)
              : VanepAvatarStack(names: names),
          title:
              single?.name ??
              l10n.clientHomeChildrenWithoutRoute(joinNames(l10n, names)),
          subtitle: single != null
              ? noRouteReasonForSingleChild(l10n, single)
              : children
                    .map((child) => noRouteReasonSentence(l10n, child))
                    .join(' · '),
          onTap: () =>
              openUnavailableFeature(context, l10n.clientHomeShortcutProposals),
        ),
      ],
    );
  }
}
