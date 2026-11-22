import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_former_link.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_former_links_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

String formatFullDate(DateTime date) =>
    '${formatDayAndMonth(date)}/${date.year}';

class AssistantFormerLinksPage extends StatelessWidget {
  const AssistantFormerLinksPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantFormerLinksCubit>(
        create: (_) => getIt<AssistantFormerLinksCubit>()..loadFormerLinks(),
        child: const AssistantFormerLinksPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: AppBar(
        backgroundColor: context.palette.surface,
        title: Text(l10n.assistantFormerLinksTitle),
      ),
      body: BlocBuilder<AssistantFormerLinksCubit, AssistantFormerLinksState>(
        builder: (context, state) => switch (state.status) {
          AssistantFormerLinksStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          AssistantFormerLinksStatus.loadFailed => Padding(
            padding: assistantHomePagePadding,
            child: VanepErrorView(
              message: assistantFailureMessage(l10n, state.failure!),
              retryLabel: l10n.assistantHomeRetry,
              onRetry: () =>
                  context.read<AssistantFormerLinksCubit>().loadFormerLinks(),
            ),
          ),
          AssistantFormerLinksStatus.ready => AssistantFormerLinksBody(
            links: state.links,
          ),
        },
      ),
    );
  }
}

class AssistantFormerLinksBody extends StatelessWidget {
  const AssistantFormerLinksBody({required this.links, super.key});

  final List<AssistantFormerLink> links;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        Text(l10n.assistantFormerLinksInfo, style: typography.cardSubtitle),
        const SizedBox(height: assistantHomeSectionSpacing),
        if (links.isEmpty)
          Text(l10n.assistantFormerLinksEmpty, style: typography.cardSubtitle),
        for (final link in links) ...[
          VanepCard(
            child: Row(
              children: [
                VanepInitialAvatar(
                  name: link.van.driverName,
                  seed: link.van.driverToken,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assistantHomeVanLabel(l10n, link.van),
                        style: typography.cardTitle,
                      ),
                      Text(
                        [
                              assistantVansShiftLabel(l10n, link.van.shift),
                              l10n.assistantFormerLinkPeriod(
                                formatFullDate(link.joinedAt),
                                formatFullDate(link.endedAt),
                              ),
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
          ),
          const SizedBox(height: assistantHomeItemSpacing),
        ],
      ],
    );
  }
}
