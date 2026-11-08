import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/day_event.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class ChildDayCard extends StatelessWidget {
  const ChildDayCard({required this.plan, super.key});

  final ChildDayPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          Row(
            children: [
              VanepPersonAvatar(name: plan.childName, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.clientHomeChildDayTitle(plan.childName),
                  style: context.typography.cardTitle,
                ),
              ),
              TextButton(
                onPressed: () =>
                    openUnavailableFeature(context, l10n.clientHomeHistory),
                child: Text(
                  l10n.clientHomeHistory,
                  style: context.typography.linkAction,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final milestone in plan.milestones)
            DayMilestoneRow(milestone: milestone),
        ],
      ),
    );
  }
}

class DayMilestoneRow extends StatelessWidget {
  const DayMilestoneRow({required this.milestone, super.key});

  final DayMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final time = formatTimeOfDay(l10n, milestone.at);
    final place = milestone.placeLabel;
    final emphasis = milestone.current;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            emphasis
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 22,
            color: emphasis ? context.palette.action : context.palette.divider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatMilestone(l10n, milestone.kind),
                  style: context.typography.body.copyWith(
                    fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (place != null)
                  Text(
                    l10n.clientHomeTodayPlace(place),
                    style: context.typography.cardSubtitle.copyWith(
                      color: context.palette.action,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            milestone.estimated ? l10n.clientHomeApproximateTime(time) : time,
            style: context.typography.cardSubtitle.copyWith(
              color: emphasis
                  ? context.palette.action
                  : context.palette.textSecondary,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

const arrivalSurface = Color(0x141E8E5A);

class ArrivalCard extends StatelessWidget {
  const ArrivalCard({required this.section, super.key});

  final ArrivedSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final returnPlace = section.returnPlaceLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: arrivalSurface,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        border: Border.all(
          color: context.palette.success.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                HomeIconBubble(
                  icon: Icons.school_outlined,
                  background: context.palette.success,
                  foreground: VanepColors.onBrand,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n
                            .clientHomeConfirmedAt(
                              formatTimeOfDay(l10n, section.confirmedAt),
                            )
                            .toUpperCase(),
                        style: context.typography.cardSubtitle.copyWith(
                          color: context.palette.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        l10n.clientHomeArrivedAtSchool(section.childName),
                        style: context.typography.heading.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        section.schoolName,
                        style: context.typography.cardSubtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            VanepCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: context.palette.action, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: context.typography.body,
                        children: [
                          TextSpan(
                            text: l10n.clientHomeSchoolDepartureAt(
                              formatTimeOfDay(l10n, section.schoolDepartureAt),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (returnPlace != null)
                            TextSpan(
                              text: l10n.clientHomeReturnsTo(returnPlace),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData dayEventIcon(DayEventKind kind) {
  return switch (kind) {
    DayEventKind.droppedAtSchool || DayEventKind.boardedAtHome => Icons.check,
    DayEventKind.routeStarted => Icons.airport_shuttle_outlined,
    DayEventKind.absence => Icons.event_busy_outlined,
  };
}

String dayEventTitle(AppLocalizations l10n, DayEvent event) {
  return switch (event.kind) {
    DayEventKind.droppedAtSchool => l10n.clientHomeEventDroppedAtSchool,
    DayEventKind.boardedAtHome => l10n.clientHomeEventBoardedAtHome,
    DayEventKind.routeStarted => l10n.clientHomeEventRouteStarted,
    DayEventKind.absence => l10n.clientHomeNotGoingToday(event.childName ?? ''),
  };
}

class DayTimelineCard extends StatelessWidget {
  const DayTimelineCard({required this.events, super.key});

  final List<DayEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final newestFirst = [...events]..sort((a, b) => b.at.compareTo(a.at));

    return VanepCard(
      child: Column(
        children: [
          for (final event in newestFirst)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      formatClockTime(event.at),
                      style: context.typography.ratingLabel,
                    ),
                  ),
                  HomeIconBubble(
                    icon: dayEventIcon(event.kind),
                    size: 24,
                    background: event.kind == DayEventKind.absence
                        ? context.palette.warningSurface
                        : event.kind == DayEventKind.routeStarted
                        ? context.palette.actionSurface
                        : context.palette.success,
                    foreground: event.kind == DayEventKind.absence
                        ? context.palette.warning
                        : event.kind == DayEventKind.routeStarted
                        ? context.palette.action
                        : VanepColors.onBrand,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayEventTitle(l10n, event),
                          style: context.typography.cardTitle.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        if (event.actorName != null)
                          Text(
                            l10n.clientHomeEventBy(event.actorName!),
                            style: context.typography.cardSubtitle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AlertsPreferencesRow extends StatelessWidget {
  const AlertsPreferencesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HomeRowsCard(
      rows: [
        HomeRowTile(
          leading: Icon(
            Icons.notifications_active_outlined,
            color: context.palette.textSecondary,
          ),
          title: l10n.clientHomeAlertsTitle,
          subtitle: l10n.clientHomeAlertsMessage,
          onTap: () =>
              openUnavailableFeature(context, l10n.clientHomeAlertsTitle),
        ),
      ],
    );
  }
}

class NoRouteTodayCard extends StatelessWidget {
  const NoRouteTodayCard({required this.section, super.key});

  final NoRouteTodaySection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayWithoutReturn = section.firstDayWithoutReturn;

    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HomeIconBubble(icon: Icons.weekend_outlined, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.clientHomeNoRouteToday,
                      style: context.typography.heading.copyWith(fontSize: 20),
                    ),
                    Text(
                      l10n.clientHomeNextRoute(
                        formatWeekday(l10n, section.nextRouteAt),
                        formatTimeOfDay(l10n, section.nextRouteAt),
                      ),
                      style: context.typography.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (index, day) in section.week.indexed) ...[
                if (index > 0) const SizedBox(width: 6),
                Expanded(child: WeekDayTile(day: day)),
              ],
            ],
          ),
          if (dayWithoutReturn != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.clientHomeReturnWithYou(
                formatWeekday(l10n, dayWithoutReturn.date),
              ),
              style: context.typography.cardSubtitle,
            ),
          ],
        ],
      ),
    );
  }
}

class WeekDayTile extends StatelessWidget {
  const WeekDayTile({required this.day, super.key});

  final WeekDayPlan day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(VanepTheme.controlRadius),
      ),
      child: Column(
        children: [
          Text(
            formatShortWeekday(l10n, day.date),
            style: context.typography.cardSubtitle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text('${day.date.day}', style: context.typography.cardTitle),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: LegMark(active: day.going)),
              const SizedBox(width: 3),
              Expanded(child: LegMark(active: day.returning)),
            ],
          ),
        ],
      ),
    );
  }
}

class LegMark extends StatelessWidget {
  const LegMark({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: active ? context.palette.action : context.palette.card,
        borderRadius: BorderRadius.circular(3),
        border: active ? null : Border.all(color: context.palette.inputBorder),
      ),
    );
  }
}
