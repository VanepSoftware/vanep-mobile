import 'package:flutter/material.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/day_progress_cards.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/first_access_extras.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/first_steps_card.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/live_van_card.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/negotiating_card.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/no_linked_van_card.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/van_day_cards.dart';

List<Widget> withSpacing(List<Widget> children) {
  return [
    for (final (index, child) in children.indexed) ...[
      if (index > 0) const SizedBox(height: homeCardSpacing),
      child,
    ],
  ];
}

class TodaySectionView extends StatelessWidget {
  const TodaySectionView({
    required this.section,
    required this.now,
    required this.onFindVanTapped,
    required this.onAddAddressTapped,
    required this.onAddDependentTapped,
    super.key,
  });

  final TodaySection section;
  final DateTime now;
  final VoidCallback onFindVanTapped;
  final VoidCallback onAddAddressTapped;
  final VoidCallback onAddDependentTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final section = this.section;
    final todayHeader = HomeSectionHeader(title: l10n.clientHomeTodayTitle);

    final children = switch (section) {
      FirstStepsSection() => withSpacing([
        FirstStepsCard(
          steps: section,
          onAddAddressTapped: onAddAddressTapped,
          onAddDependentTapped: onAddDependentTapped,
        ),
        const DriverInviteRow(),
      ]),
      NoLinkedVanSection() => [
        todayHeader,
        NoLinkedVanCard(onFindVanTapped: onFindVanTapped),
      ],
      NegotiatingSection() => [
        todayHeader,
        NegotiatingCard(section: section, onSearchVansTapped: onFindVanTapped),
      ],
      VanDaySection() => [todayHeader, ...withSpacing(vanDayCards(section))],
      ArrivedSection() => [
        ArrivalCard(section: section),
        const SizedBox(height: homeBlockSpacing),
        HomeSectionHeader(
          title: l10n.clientHomeTodayTitle,
          actionLabel: l10n.clientHomeSeeAll,
          onAction: () =>
              openUnavailableFeature(context, l10n.clientHomeHistory),
        ),
        ...withSpacing([
          DayTimelineCard(events: section.events),
          const AlertsPreferencesRow(),
        ]),
      ],
      NoRouteTodaySection() => [NoRouteTodayCard(section: section)],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  List<Widget> vanDayCards(VanDaySection section) {
    final expanded = section.expandedVan;
    final live = expanded?.live;
    final childDay = section.childDay;
    return [
      if (expanded != null && live != null)
        LiveVanCard(van: expanded, live: live, now: now)
      else if (expanded != null)
        VanDayCard(van: expanded),
      if (childDay != null) ChildDayCard(plan: childDay),
      for (final van in section.collapsedVans) VanDayRow(van: van),
      if (section.childrenWithoutRoute.isNotEmpty)
        ChildrenWithoutRouteRow(children: section.childrenWithoutRoute),
    ];
  }
}
