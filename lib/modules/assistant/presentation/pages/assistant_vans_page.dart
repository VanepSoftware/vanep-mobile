import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_confirm_dialog.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_feedback.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/respond_to_assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_vans_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_vans_cards.dart';

const assistantVansPagePadding = EdgeInsets.fromLTRB(20, 24, 20, 24);

const assistantVansCardSpacing = 12.0;

class AssistantVansPage extends StatelessWidget {
  const AssistantVansPage({super.key});

  static Widget withCubit() {
    return BlocProvider<AssistantVansCubit>(
      create: (_) => getIt<AssistantVansCubit>()..loadVans(),
      child: const AssistantVansPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: Navigator.of(context).canPop()
          ? AppBar(
              backgroundColor: context.palette.surface,
              surfaceTintColor: context.palette.surface,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: BlocConsumer<AssistantVansCubit, AssistantVansState>(
          listenWhen: (previous, current) =>
              current.notice != null && previous.notice != current.notice,
          listener: showAssistantVansNotice,
          builder: (context, state) => AssistantVansBody(state: state),
        ),
      ),
    );
  }
}

class AssistantVansBody extends StatelessWidget {
  const AssistantVansBody({required this.state, super.key});

  final AssistantVansState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: assistantVansPagePadding,
      children: [
        Text(l10n.assistantVansTitle, style: context.typography.pageTitle),
        const SizedBox(height: 4),
        Text(
          l10n.assistantVansSubtitle,
          style: context.typography.cardSubtitle,
        ),
        const SizedBox(height: 20),
        switch (state.status) {
          AssistantVansStatus.loading => const AssistantVansSkeleton(),
          AssistantVansStatus.loadFailed => VanepErrorView(
            message: assistantFailureMessage(l10n, state.failure!),
            retryLabel: l10n.assistantVansRetry,
            onRetry: () => context.read<AssistantVansCubit>().loadVans(),
          ),
          AssistantVansStatus.ready => AssistantVansContent(
            overview: state.overview!,
            respondingInvite: state.respondingInvite,
          ),
        },
      ],
    );
  }
}

class AssistantVansContent extends StatelessWidget {
  const AssistantVansContent({
    required this.overview,
    this.respondingInvite,
    super.key,
  });

  final AssistantVansOverview overview;

  final InviteResponse? respondingInvite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invite = overview.pendingInvite;

    if (overview.isEmpty) {
      return Text(
        l10n.assistantVansEmpty,
        textAlign: TextAlign.center,
        style: context.typography.cardSubtitle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (invite != null) ...[
          Text(
            l10n.assistantVansPendingInviteSection,
            style: context.typography.sectionTitle,
          ),
          const SizedBox(height: assistantVansCardSpacing),
          AssistantPendingInviteCard(
            invite: invite,
            daysLeft: daysUntilInviteExpires(invite.expiresAt, DateTime.now()),
            respondingInvite: respondingInvite,
            onAccept: () => context.read<AssistantVansCubit>().respondToInvite(
              InviteResponse.accept,
            ),
            onDecline: () => confirmInviteDecline(context),
          ),
          const SizedBox(height: 24),
        ],
        if (overview.activeVans.isNotEmpty) ...[
          Text(
            l10n.assistantVansActiveSection,
            style: context.typography.sectionTitle,
          ),
          const SizedBox(height: assistantVansCardSpacing),
          for (final (vanIndex, summary) in overview.activeVans.indexed) ...[
            AssistantVanCard(summary: summary, toneIndex: vanIndex),
            const SizedBox(height: assistantVansCardSpacing),
          ],
        ],
        if (overview.formerVanCount > 0) ...[
          const SizedBox(height: 4),
          AssistantFormerVansTile(count: overview.formerVanCount),
        ],
      ],
    );
  }
}

class AssistantVansSkeleton extends StatelessWidget {
  const AssistantVansSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VanepSkeletonList(
      count: 2,
      spacing: assistantVansCardSpacing,
      buildPlaceholder: (_) => const VanepCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone.text(words: 2, fontSize: 16),
            SizedBox(height: 8),
            Bone.text(words: 4, fontSize: 13),
            SizedBox(height: 16),
            Bone(
              height: 52,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}

void showAssistantVansNotice(BuildContext context, AssistantVansState state) {
  final l10n = AppLocalizations.of(context)!;
  final notice = state.notice;
  switch (notice) {
    case InviteRespondedNotice(response: InviteResponse.accept):
      VanepFeedback.showInfo(context, l10n.assistantVansInviteAccepted);
    case InviteRespondedNotice(response: InviteResponse.reject):
      VanepFeedback.showInfo(context, l10n.assistantVansInviteDeclined);
    case InviteResponseFailedNotice(:final failure):
      VanepFeedback.showError(context, assistantFailureMessage(l10n, failure));
    case null:
      return;
  }
  context.read<AssistantVansCubit>().clearNotice();
}

Future<void> confirmInviteDecline(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<AssistantVansCubit>();
  final confirmed = await showVanepConfirmDialog(
    context: context,
    title: l10n.assistantVansDeclineConfirmTitle,
    message: l10n.assistantVansDeclineConfirmMessage,
    confirmLabel: l10n.assistantVansDecline,
    cancelLabel: l10n.assistantVansDeclineConfirmCancel,
    isDestructive: true,
  );
  if (confirmed) await cubit.respondToInvite(InviteResponse.reject);
}
