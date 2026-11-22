import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_segmented_control.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/derive_assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_row_state.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

class AssistantRouteStopsPage extends StatefulWidget {
  const AssistantRouteStopsPage({super.key});

  static Route<void> route(AssistantHomeCubit cubit) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantHomeCubit>.value(
        value: cubit,
        child: const AssistantRouteStopsPage(),
      ),
    );
  }

  static Route<void> routeOfVan(String vanToken) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantHomeCubit>(
        create: (_) =>
            getIt<AssistantHomeCubit>()..load(selectedVanToken: vanToken),
        child: const AssistantRouteStopsPage(),
      ),
    );
  }

  @override
  State<AssistantRouteStopsPage> createState() =>
      _AssistantRouteStopsPageState();
}

class _AssistantRouteStopsPageState extends State<AssistantRouteStopsPage> {
  TripLeg? chosenLeg;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<AssistantHomeCubit>().state;
    final route = state.route;
    final link = selectAssistantVanLink(
      state.overview?.links ?? const [],
      state.selectedVanToken,
    );
    final leg = chosenLeg ?? route?.currentLeg ?? TripLeg.outbound;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: AppBar(
        backgroundColor: context.palette.surface,
        title: Text(l10n.assistantHomeShortcutRoute),
      ),
      body: route == null
          ? Center(
              child: state.status == AssistantHomeLoadStatus.loading
                  ? const CircularProgressIndicator()
                  : Text(
                      l10n.assistantHomeNoTripToday,
                      style: context.typography.cardSubtitle,
                    ),
            )
          : ListView(
              padding: assistantHomePagePadding,
              children: [
                if (link != null)
                  Text(
                    l10n.assistantStopsSubtitle(
                      firstNameOf(link.van.driverName),
                      assistantVansShiftLabel(l10n, link.van.shift),
                      l10n.assistantHomeStopsCount(route.stopCountOf(leg)),
                    ),
                    style: context.typography.cardSubtitle,
                  ),
                const SizedBox(height: assistantHomeItemSpacing),
                VanepSegmentedControl<TripLeg>(
                  segments: [
                    VanepSegment(
                      value: TripLeg.outbound,
                      label: l10n.assistantStopsOutbound,
                    ),
                    VanepSegment(
                      value: TripLeg.inbound,
                      label: l10n.assistantStopsReturn,
                    ),
                  ],
                  selected: leg,
                  onSelected: (selected) =>
                      setState(() => chosenLeg = selected),
                ),
                const SizedBox(height: assistantHomeItemSpacing),
                for (final stop in route.stopsOf(leg))
                  AssistantRouteStopRow(route: route, stop: stop),
                const SizedBox(height: assistantHomeSectionSpacing),
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: context.palette.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.assistantStopsOrderByDriver,
                        style: context.typography.cardSubtitle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class AssistantRouteStopRow extends StatelessWidget {
  const AssistantRouteStopRow({
    required this.route,
    required this.stop,
    super.key,
  });

  final AssistantRouteSnapshot route;
  final AssistantRouteStop stop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final typography = context.typography;
    final languageCode = Localizations.localeOf(context).languageCode;
    final rowState = route.stopRowStateOf(stop);
    final completedAt = stop.completedAt;
    final plannedAt = stop.plannedArrivalAt;

    final time = switch (rowState) {
      StopRowState.current => l10n.assistantOnboardNow,
      StopRowState.done || StopRowState.doneWithIssue
          when completedAt != null =>
        formatClockTime(completedAt, languageCode: languageCode),
      _ when plannedAt != null =>
        '~${formatClockTime(plannedAt, languageCode: languageCode)}',
      _ => '',
    };

    final Widget marker = switch (rowState) {
      StopRowState.done => Icon(Icons.check_circle, color: palette.success),
      StopRowState.doneWithIssue => Icon(Icons.error, color: palette.warning),
      _ when stop.kind.isAtSchool => Icon(
        Icons.school,
        color: rowState == StopRowState.current
            ? palette.action
            : palette.textSecondary,
      ),
      _ => CircleAvatar(
        radius: 13,
        backgroundColor: rowState == StopRowState.current
            ? palette.action
            : palette.actionSurface,
        child: Text(
          '${route.stopNumberOf(stop)}',
          style: typography.ratingLabel.copyWith(
            color: rowState == StopRowState.current
                ? palette.onAction
                : palette.action,
          ),
        ),
      ),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: rowState == StopRowState.current,
      leading: marker,
      title: Text(stop.label, style: typography.cardTitle),
      subtitle: Text(stopRouteLine(l10n, stop), style: typography.cardSubtitle),
      trailing: Text(time, style: typography.ratingLabel),
    );
  }
}
