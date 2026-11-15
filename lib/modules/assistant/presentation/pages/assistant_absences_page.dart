import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absences_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_absences_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_absences_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_absences_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/mappers/assistant_failure_l10n.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_home_cards.dart';

class AssistantAbsencesPage extends StatelessWidget {
  const AssistantAbsencesPage({required this.vanToken, super.key});

  final String vanToken;

  static Route<void> route(String vanToken) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<AssistantAbsencesCubit>(
        create: (_) => getIt<AssistantAbsencesCubit>()..loadAbsences(vanToken),
        child: AssistantAbsencesPage(vanToken: vanToken),
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
        title: Text(l10n.assistantHomeShortcutAbsences),
      ),
      body: BlocBuilder<AssistantAbsencesCubit, AssistantAbsencesState>(
        builder: (context, state) => switch (state.status) {
          AssistantAbsencesStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          AssistantAbsencesStatus.loadFailed => Padding(
            padding: assistantHomePagePadding,
            child: VanepErrorView(
              message: assistantFailureMessage(l10n, state.failure!),
              retryLabel: l10n.assistantHomeRetry,
              onRetry: () =>
                  context.read<AssistantAbsencesCubit>().loadAbsences(vanToken),
            ),
          ),
          AssistantAbsencesStatus.ready => AssistantAbsencesBody(
            overview: state.overview!,
          ),
        },
      ),
    );
  }
}

class AssistantAbsencesBody extends StatelessWidget {
  const AssistantAbsencesBody({required this.overview, super.key});

  final AssistantAbsencesOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;

    return ListView(
      padding: assistantHomePagePadding,
      children: [
        VanepSection(
          title: l10n.assistantAbsencesToday,
          child: overview.today.isEmpty
              ? Text(
                  l10n.assistantAbsencesNobodyToday,
                  style: typography.cardSubtitle,
                )
              : Column(
                  children: [
                    for (final row in overview.today)
                      AssistantAbsenceTile(row: row, isToday: true),
                  ],
                ),
        ),
        if (overview.upcoming.isNotEmpty) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          VanepSection(
            title: l10n.assistantAbsencesUpcoming,
            child: Column(
              children: [
                for (final row in overview.upcoming)
                  AssistantAbsenceTile(row: row, isToday: false),
              ],
            ),
          ),
        ],
        const SizedBox(height: assistantHomeSectionSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: context.palette.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.assistantAbsencesFooter,
                style: typography.cardSubtitle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AssistantAbsenceTile extends StatelessWidget {
  const AssistantAbsenceTile({
    required this.row,
    required this.isToday,
    super.key,
  });

  final AssistantAbsenceRow row;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (background, foreground) = absenceKindTones(
      context.palette,
      row.kind,
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: VanepInitialAvatar(
        name: row.passengerNames.first,
        seed: row.passengerTokens.first,
        size: 36,
      ),
      title: Text(
        joinFirstNames(l10n, row.passengerNames),
        style: context.typography.cardTitle,
      ),
      subtitle: Text(
        absenceRowDetail(
          l10n,
          row,
          isToday: isToday,
          now: DateTime.now(),
          languageCode: Localizations.localeOf(context).languageCode,
        ),
        style: context.typography.cardSubtitle,
      ),
      trailing: VanepChip(
        label: absenceKindLabel(l10n, row.kind),
        background: background,
        foreground: foreground,
      ),
    );
  }
}
