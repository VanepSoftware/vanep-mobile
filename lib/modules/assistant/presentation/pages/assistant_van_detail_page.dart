import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_detail_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_route_stops_page.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

class AssistantVanDetailPage extends StatelessWidget {
  const AssistantVanDetailPage({required this.vanToken, super.key});

  final String vanToken;

  static Route<bool> route(String vanToken) {
    return MaterialPageRoute<bool>(
      builder: (_) => BlocProvider<AssistantVanDetailCubit>(
        create: (_) => getIt<AssistantVanDetailCubit>()..loadDetail(vanToken),
        child: AssistantVanDetailPage(vanToken: vanToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<AssistantVanDetailCubit, AssistantVanDetailState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.failure != current.failure,
      listener: (context, state) {
        if (state.status == AssistantVanDetailStatus.left) {
          Navigator.of(context).pop(true);
          return;
        }
        final failure = state.failure;
        if (failure != null && state.status == AssistantVanDetailStatus.ready) {
          VanepFeedback.showError(
            context,
            assistantFailureMessage(l10n, failure),
          );
        }
      },
      builder: (context, state) {
        final detail = state.detail;
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(
            backgroundColor: context.palette.surface,
            title: Text(
              detail == null
                  ? ''
                  : l10n.assistantVansVanTitle(
                      firstNameOf(detail.van.driverName),
                    ),
            ),
          ),
          body: switch (state.status) {
            AssistantVanDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            AssistantVanDetailStatus.loadFailed => Padding(
              padding: assistantHomePagePadding,
              child: VanepErrorView(
                message: assistantFailureMessage(l10n, state.failure!),
                retryLabel: l10n.assistantHomeRetry,
                onRetry: () => context
                    .read<AssistantVanDetailCubit>()
                    .loadDetail(vanToken),
              ),
            ),
            _ => AssistantVanDetailBody(
              detail: detail!,
              isLeaving: state.isLeaving,
            ),
          },
        );
      },
    );
  }
}

class AssistantVanDetailBody extends StatelessWidget {
  const AssistantVanDetailBody({
    required this.detail,
    required this.isLeaving,
    super.key,
  });

  final AssistantVanDetail detail;
  final bool isLeaving;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final typography = context.typography;
    final languageCode = Localizations.localeOf(context).languageCode;
    final van = detail.van;
    final departure = detail.departureAt;
    final isActive = detail.linkStatus == AssistantLinkStatus.active;

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        Text(
          [van.model, van.plate].join(vanSubtitleSeparator),
          style: typography.cardSubtitle,
        ),
        const SizedBox(height: assistantHomeItemSpacing),
        Align(
          alignment: Alignment.centerLeft,
          child: VanepChip(
            label: isActive
                ? l10n.assistantVanDetailActive
                : l10n.assistantVanDetailPaused,
            background: isActive
                ? palette.successSurface
                : palette.warningSurface,
            foreground: isActive ? palette.success : palette.warning,
          ),
        ),
        const SizedBox(height: assistantHomeItemSpacing),
        VanepCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  VanepInitialAvatar(
                    name: van.driverName,
                    seed: van.driverToken,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(van.driverName, style: typography.cardTitle),
                        Text(
                          l10n.assistantVanDetailDriver,
                          style: typography.cardSubtitle,
                        ),
                      ],
                    ),
                  ),
                  // TODO(VAN-69): the driver phone is not exposed to the
                  // assistant yet (backend B6); enable the call when it is.
                  IconButton(
                    tooltip: l10n.assistantHomeCallDriverNamed(
                      firstNameOf(van.driverName),
                    ),
                    onPressed: null,
                    icon: const Icon(Icons.call),
                  ),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (departure != null)
                    Text(
                      [
                            assistantVansShiftLabel(l10n, van.shift),
                            l10n.assistantVansDeparture(
                              formatClockTime(
                                departure,
                                languageCode: languageCode,
                              ),
                            ),
                          ]
                          .where((part) => part.isNotEmpty)
                          .join(vanSubtitleSeparator),
                      style: typography.body,
                    ),
                  Text(
                    l10n.assistantHomeStudentsCount(detail.studentsCount),
                    style: typography.body,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: assistantHomeSectionSpacing),
        AssistantCapabilitiesList(
          title: l10n.assistantVanDetailCapabilitiesTitle,
          capabilities: [
            l10n.assistantHomeCapabilityConfirm,
            l10n.assistantHomeCapabilityNoShow,
            l10n.assistantVanDetailCapabilityStops,
          ],
          restriction: l10n.assistantVanDetailOnlyDriverOrders(
            firstNameOf(van.driverName),
          ),
          restrictionIcon: Icons.lock_outline,
        ),
        const SizedBox(height: assistantHomeSectionSpacing),
        VanepSection(
          title: l10n.assistantVanDetailStopsTitle(
            assistantVansShiftLabel(l10n, van.shift),
          ),
          child: Column(
            children: [
              for (final stop in detail.previewStops)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 13,
                    backgroundColor: palette.actionSurface,
                    child: Text(
                      '${stop.sequence}',
                      style: typography.ratingLabel.copyWith(
                        color: palette.action,
                      ),
                    ),
                  ),
                  title: Text(stop.label, style: typography.cardTitle),
                  subtitle: Text(
                    stopPassengersLine(l10n, stop),
                    style: typography.cardSubtitle,
                  ),
                  trailing: stop.plannedArrivalAt == null
                      ? null
                      : Text(
                          formatClockTime(
                            stop.plannedArrivalAt!,
                            languageCode: languageCode,
                          ),
                          style: typography.ratingLabel,
                        ),
                ),
              if (detail.stops.length > detail.previewStops.length)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(AssistantRouteStopsPage.routeOfVan(van.token)),
                    child: Text(
                      l10n.assistantVanDetailAllStops(detail.stops.length),
                      style: typography.linkAction,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: assistantHomeSectionSpacing),
        TextButton.icon(
          onPressed: isLeaving ? null : () => confirmLeaving(context),
          icon: Icon(Icons.logout, color: palette.danger),
          label: Text(
            l10n.assistantVanDetailLeave,
            style: typography.linkAction.copyWith(color: palette.danger),
          ),
        ),
      ],
    );
  }

  Future<void> confirmLeaving(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AssistantVanDetailCubit>();
    final confirmed = await showVanepConfirmDialog(
      context: context,
      title: l10n.assistantVanDetailLeaveTitle,
      message: l10n.assistantVanDetailLeaveMessage(
        firstNameOf(detail.van.driverName),
      ),
      confirmLabel: l10n.assistantVanDetailLeave,
      cancelLabel: l10n.assistantVanDetailKeep,
    );
    if (confirmed) await cubit.leaveVan();
  }
}
