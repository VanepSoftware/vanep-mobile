import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_state.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/formatters/van_central_labels.dart';

/// Opens the driver's assistant team (GET /api/assistants), reusing the
/// [VanCentralCubit] that already loaded it for the menu summary.
Future<void> openVanAssistants(BuildContext context) {
  final cubit = context.read<VanCentralCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<VanCentralCubit>.value(
        value: cubit,
        child: const VanAssistantsPage(),
      ),
    ),
  );
}

class VanAssistantsPage extends StatelessWidget {
  const VanAssistantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: AppBar(title: Text(l10n.vanCentralAssistants)),
      body: BlocBuilder<VanCentralCubit, VanCentralState>(
        builder: (context, state) {
          final team = state.assistants;
          return RefreshIndicator(
            color: context.palette.action,
            onRefresh: context.read<VanCentralCubit>().refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (team == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(
                      l10n.vanAssistantsLoadError,
                      textAlign: TextAlign.center,
                      style: context.typography.cardSubtitle,
                    ),
                  )
                else ...[
                  Text(
                    assistantsSummary(l10n, team),
                    style: context.typography.cardSubtitle,
                  ),
                  const SizedBox(height: 16),
                  if (team.isEmpty)
                    Text(
                      l10n.vanAssistantsEmpty,
                      style: context.typography.cardSubtitle,
                    ),
                  for (final assistant in sortedTeam(team)) ...[
                    VanAssistantTile(assistant: assistant),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Working assistants first, then pending invites, then the rest.
List<VanAssistant> sortedTeam(List<VanAssistant> team) {
  int rank(VanAssistant assistant) => switch (assistant.status) {
    VanAssistantStatus.active => 0,
    VanAssistantStatus.pending => 1,
    VanAssistantStatus.inactive => 2,
    VanAssistantStatus.unlinked => 3,
  };
  return [...team]..sort((a, b) => rank(a).compareTo(rank(b)));
}

class VanAssistantTile extends StatelessWidget {
  const VanAssistantTile({required this.assistant, super.key});

  final VanAssistant assistant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final (label, color) = switch (assistant.status) {
      VanAssistantStatus.active => (
        l10n.vanAssistantStatusActive,
        palette.success,
      ),
      VanAssistantStatus.pending => (
        l10n.vanAssistantStatusPending,
        palette.warning,
      ),
      VanAssistantStatus.inactive => (
        l10n.vanAssistantStatusInactive,
        palette.textSecondary,
      ),
      VanAssistantStatus.unlinked => (
        l10n.vanAssistantStatusUnlinked,
        palette.textMuted,
      ),
    };
    final activatedAt = assistant.activatedAt;
    final details = [
      ?assistant.email,
      if (activatedAt != null && assistant.isWorking)
        l10n.vanAssistantSince(
          DateFormat.yMd(l10n.localeName).format(activatedAt.toLocal()),
        ),
    ];

    return VanepCard(
      child: Row(
        children: [
          VanepPersonAvatar(name: assistant.name, dimmed: !assistant.isWorking),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assistant.name,
                  style: context.typography.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                for (final line in details)
                  Text(
                    line,
                    style: context.typography.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.typography.ratingLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
