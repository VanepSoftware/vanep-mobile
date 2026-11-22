import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/share/text_sharer.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/confirm_stop_passengers.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_skip_reason_sheet.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_van_selector_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_route_widgets.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_vans_cards.dart';

const assistantHomePagePadding = EdgeInsets.fromLTRB(20, 24, 20, 24);

class AssistantHomeTab extends StatelessWidget {
  const AssistantHomeTab({
    required this.displayName,
    this.email,
    this.showVanChips = true,
    super.key,
  });

  final String displayName;
  final String? email;
  final bool showVanChips;

  static Widget withCubit({
    required String displayName,
    String? email,
    AssistantVanSelectorCubit? vanSelector,
  }) {
    final home = AssistantHomeTab(
      displayName: displayName,
      email: email,
      showVanChips: vanSelector == null,
    );
    return BlocProvider<AssistantHomeCubit>(
      create: (_) =>
          getIt<AssistantHomeCubit>()
            ..load(selectedVanToken: vanSelector?.state.selectedVan?.token),
      child: vanSelector == null
          ? home
          : BlocListener<AssistantVanSelectorCubit, AssistantVanSelectorState>(
              bloc: vanSelector,
              listenWhen: (previous, current) =>
                  previous.selectedVan?.token != current.selectedVan?.token,
              listener: (context, state) {
                final token = state.selectedVan?.token;
                if (token != null) {
                  context.read<AssistantHomeCubit>().selectVan(token);
                }
              },
              child: home,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: BlocConsumer<AssistantHomeCubit, AssistantHomeState>(
          listener: (context, state) =>
              showAssistantHomeFeedback(context, state),
          listenWhen: (previous, current) =>
              previous.lastConfirmation != current.lastConfirmation ||
              previous.actionFailure != current.actionFailure,
          builder: (context, state) => AssistantHomeBody(
            state: state,
            displayName: displayName,
            email: email,
            showVanChips: showVanChips,
          ),
        ),
      ),
    );
  }
}

void showAssistantHomeFeedback(BuildContext context, AssistantHomeState state) {
  final l10n = AppLocalizations.of(context)!;
  final failure = state.actionFailure;
  if (failure != null) {
    VanepFeedback.showError(context, assistantFailureMessage(l10n, failure));
    return;
  }
  final confirmation = state.lastConfirmation;
  if (confirmation == null) return;
  VanepFeedback.showInfoWithAction(
    context,
    l10n.assistantHomeStopConfirmed(confirmation.confirmedCount),
    actionLabel: l10n.assistantHomeUndo,
    onAction: () => context.read<AssistantHomeCubit>().undoLastConfirmation(),
  );
}

class AssistantHomeBody extends StatelessWidget {
  const AssistantHomeBody({
    required this.state,
    required this.displayName,
    this.email,
    this.showVanChips = true,
    super.key,
  });

  final AssistantHomeState state;
  final String displayName;
  final String? email;
  final bool showVanChips;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AssistantHomeCubit>();
    final links = state.overview?.links ?? const [];
    final selectedVanToken = state.selectedVanToken;
    final homeStatus = state.homeStatus;
    final hasActiveVan = switch (homeStatus) {
      AssistantHomeBeforeRoute() ||
      AssistantHomeOnRouteBoarding() ||
      AssistantHomeOnRouteDropOff() => true,
      _ => false,
    };

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        Text(
          l10n.assistantHomeGreeting(firstNameOf(displayName)),
          style: context.typography.pageTitle,
        ),
        const SizedBox(height: assistantHomeItemSpacing),
        if (showVanChips && links.length > 1 && selectedVanToken != null) ...[
          AssistantVanChips(
            links: links,
            selectedVanToken: selectedVanToken,
            onSelected: cubit.selectVan,
          ),
          const SizedBox(height: assistantHomeSectionSpacing),
        ],
        switch (state.status) {
          AssistantHomeLoadStatus.loading => const AssistantHomeSkeleton(),
          AssistantHomeLoadStatus.loadFailed => VanepErrorView(
            message: assistantFailureMessage(l10n, state.failure!),
            retryLabel: l10n.assistantHomeRetry,
            onRetry: () => cubit.load(selectedVanToken: selectedVanToken),
          ),
          AssistantHomeLoadStatus.ready => AssistantHomeStatusContent(
            status: homeStatus,
            state: state,
            email: email,
          ),
        },
        const SizedBox(height: assistantHomeSectionSpacing),
        AssistantHomeShortcuts(
          isEnabled: hasActiveVan,
          // TODO(VAN-71): opens the route screen once it exists.
          onOpenRoute: doNothingYet,
          // TODO(VAN-72): opens the absences screen once it exists.
          onOpenAbsences: doNothingYet,
        ),
      ],
    );
  }
}

class AssistantHomeStatusContent extends StatelessWidget {
  const AssistantHomeStatusContent({
    required this.status,
    required this.state,
    this.email,
    super.key,
  });

  final AssistantHomeStatus status;
  final AssistantHomeState state;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AssistantHomeCubit>();
    const gap = SizedBox(height: assistantHomeSectionSpacing);

    final children = switch (status) {
      AssistantHomeNoVan() => [
        AssistantNoVanCard(
          email: email,
          onCopyEmail: () => copyEmail(context),
          onShareEmail: () => shareEmail(context),
        ),
        gap,
        AssistantNumberedSteps(
          title: l10n.assistantHomeHowItWorksTitle,
          steps: [
            l10n.assistantHomeHowItWorksInvite,
            l10n.assistantHomeHowItWorksAccept,
            l10n.assistantHomeHowItWorksConfirm,
          ],
        ),
        gap,
        AssistantCapabilitiesList.ofApp(l10n),
      ],
      AssistantHomeInviteReceived(:final invite) => [
        Text(l10n.assistantHomeInviteSubtitle, style: context.typography.body),
        const SizedBox(height: assistantHomeItemSpacing),
        AssistantPendingInviteCard(
          invite: invite,
          daysLeft: daysUntilInviteExpires(invite.expiresAt, DateTime.now()),
          onAccept: () => cubit.answerInvite(InviteResponse.accept),
          onReject: () => cubit.answerInvite(InviteResponse.reject),
        ),
        gap,
        AssistantCapabilitiesList.ofApp(l10n),
      ],
      AssistantHomeBeforeRoute(:final link, :final route) => [
        AssistantBeforeRouteCard(
          link: link,
          route: route,
          isPresentInVan: state.isPresentInVan,
          onPresentInVan: cubit.confirmPresenceInVan,
        ),
        if (route != null && route.todayAbsences.isNotEmpty) ...[
          gap,
          AssistantNotGoingTodayList(route: route, now: DateTime.now()),
        ],
        if (route != null) ...[
          gap,
          AssistantStopsPreview(
            title: l10n.assistantHomeFirstStops,
            stops: route.firstStops(),
            // TODO(VAN-71): opens the route screen once it exists.
            onSeeAll: doNothingYet,
          ),
        ],
      ],
      AssistantHomeOnRouteBoarding(:final link, :final route, :final stop) ||
      AssistantHomeOnRouteDropOff(:final link, :final route, :final stop) => [
        AssistantStopConfirmationCard(
          link: link,
          route: route,
          stop: stop,
          isConfirming: state.isConfirming,
          onConfirm: (selected) =>
              confirmStopWithReasons(context, route, stop, selected),
        ),
        const SizedBox(height: assistantHomeItemSpacing),
        AssistantOnBoardRow(
          route: route,
          // TODO(VAN-70): opens the on-board students screen once it exists.
          onTap: doNothingYet,
        ),
        if (route.nextStops().isNotEmpty) ...[
          gap,
          AssistantStopsPreview(
            title: l10n.assistantHomeNextStops,
            stops: route.nextStops(),
            // TODO(VAN-71): opens the route screen once it exists.
            onSeeAll: doNothingYet,
          ),
        ],
      ],
      AssistantHomeAccessPaused(:final link, :final otherActiveLinks) => [
        AssistantPausedCard(
          link: link,
          otherActiveLinks: otherActiveLinks,
          onSelectVan: cubit.selectVan,
        ),
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Future<void> copyEmail(BuildContext context) async {
    final address = email;
    if (address == null) return;
    final message = AppLocalizations.of(context)!.assistantHomeEmailCopied;
    await Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) VanepFeedback.showInfo(context, message);
  }

  Future<void> shareEmail(BuildContext context) async {
    final address = email;
    if (address == null) return;
    final l10n = AppLocalizations.of(context)!;
    await getIt<TextSharer>().shareText(
      l10n.assistantHomeShareEmailMessage(address),
    );
  }
}

class AssistantHomeSkeleton extends StatelessWidget {
  const AssistantHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: 2,
      spacing: assistantHomeItemSpacing,
      buildPlaceholder: (_) => const VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone.text(words: 2, fontSize: 13),
            SizedBox(height: 8),
            Bone.text(words: 3, fontSize: 22),
            SizedBox(height: 16),
            Bone(
              height: 60,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> confirmStopWithReasons(
  BuildContext context,
  AssistantRouteSnapshot route,
  AssistantRouteStop stop,
  Set<String> selectedPassengerTokens,
) async {
  final cubit = context.read<AssistantHomeCubit>();
  final deselected = [
    for (final passenger in route.passengersToConfirmAt(stop))
      if (!selectedPassengerTokens.contains(passenger.token)) passenger,
  ];
  if (deselected.isEmpty) {
    await cubit.confirmCurrentStop(
      selectedPassengerTokens: selectedPassengerTokens,
    );
    return;
  }
  final skipReasons = await showSkipReasonSheet(
    context,
    passengers: deselected,
    defaultReason: defaultSkipReasonAt(stop),
    isBoarding: stop.kind.isBoarding,
  );
  if (skipReasons == null) return;
  await cubit.confirmCurrentStop(
    selectedPassengerTokens: selectedPassengerTokens,
    reasons: skipReasons.reasons,
    notes: skipReasons.notes,
  );
}
