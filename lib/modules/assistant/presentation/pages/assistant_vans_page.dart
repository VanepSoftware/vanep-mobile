import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_skeleton.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
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
      backgroundColor: VanepColors.surface,
      body: SafeArea(
        child: BlocBuilder<AssistantVansCubit, AssistantVansState>(
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
        Text(l10n.assistantVansTitle, style: VanepTypography.pageTitle),
        const SizedBox(height: 4),
        Text(l10n.assistantVansSubtitle, style: VanepTypography.cardSubtitle),
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
          ),
        },
      ],
    );
  }
}

class AssistantVansContent extends StatelessWidget {
  const AssistantVansContent({required this.overview, super.key});

  final AssistantVansOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invite = overview.pendingInvite;

    if (overview.isEmpty) {
      return Text(
        l10n.assistantVansEmpty,
        textAlign: TextAlign.center,
        style: VanepTypography.cardSubtitle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (invite != null) ...[
          Text(
            l10n.assistantVansPendingInviteSection,
            style: VanepTypography.sectionTitle,
          ),
          const SizedBox(height: assistantVansCardSpacing),
          AssistantPendingInviteCard(
            invite: invite,
            daysLeft: daysUntilInviteExpires(invite.expiresAt, DateTime.now()),
          ),
          const SizedBox(height: 24),
        ],
        if (overview.activeVans.isNotEmpty) ...[
          Text(
            l10n.assistantVansActiveSection,
            style: VanepTypography.sectionTitle,
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
