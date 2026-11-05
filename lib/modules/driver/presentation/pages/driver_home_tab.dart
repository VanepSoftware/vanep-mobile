import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/ui/vanep_greeting_header.dart';
import '../../../../core/ui/vanep_home_top_bar.dart';
import '../../../../core/ui/vanep_coming_soon_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/driver_home_data.dart';
import '../cubit/driver_home_cubit.dart';
import '../cubit/driver_home_state.dart';
import '../widgets/driver_home_main_card.dart';
import '../widgets/driver_home_shortcuts.dart';
import '../widgets/driver_location_sharing_tile.dart';
import '../widgets/driver_shift_badge.dart';

class DriverHomeTab extends StatefulWidget {
  const DriverHomeTab({required this.displayName, required this.onMenuTapped,
    required this.onNotificationsTapped, this.navigation, super.key});
  final String displayName;
  final VoidCallback onMenuTapped;
  final VoidCallback onNotificationsTapped;
  final DriverHomeNavigation? navigation;

  @override
  State<DriverHomeTab> createState() => _DriverHomeTabState();
}

class _DriverHomeTabState extends State<DriverHomeTab> {
  @override
  void initState() {
    super.initState();
    context.read<DriverHomeCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DriverHomeCubit>();
    final navigation = widget.navigation ?? _PendingNavigation(context);
    return SafeArea(
      bottom: false,
      child: BlocBuilder<DriverHomeCubit, DriverHomeState>(
        builder: (context, state) {
          final data = state.data;
          final resolved = data == null ? null : cubit.rules.resolve(data);
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                VanepHomeTopBar(onMenuTapped: widget.onMenuTapped,
                  onNotificationsTapped: widget.onNotificationsTapped),
                const SizedBox(height: 8),
                VanepGreetingHeader(displayName: widget.displayName,
                  subtitle: state.shiftStartTime.isEmpty ? null
                    : l10n.driverShiftStartsAt(state.shiftStartTime)),
                const SizedBox(height: 14),
                if (state.loading || state.busy) const LinearProgressIndicator(),
                if (state.error case final String error)
                  _Notice(error, onRetry: cubit.refresh),
                if (resolved?.blockBanner case final String banner) _Notice(banner),
                if (data != null && resolved != null) ...[
                  DriverShiftBadge(onShift: state.onShift),
                  const SizedBox(height: 20),
                  // Fora do expediente apenas avisa, sem bloquear o card.
                  if (data.outsideWorkingHours)
                    const _Notice('Você está fora do expediente.'),
                  DriverHomeMainCard(data: data, phase: resolved.phase,
                    cubit: cubit, navigation: navigation,
                    enabled: !state.busy && !state.loading),
                  const SizedBox(height: 20),
                  if (cubit.rules.familyCounter(data) case final String counter)
                    Padding(padding: const EdgeInsets.only(bottom: 16),
                      child: Text(counter)),
                  DriverHomeShortcuts(data: data, rules: cubit.rules,
                    onOpen: navigation.openShortcut),
                  const SizedBox(height: 20),
                  DriverLocationSharingTile(sharing: state.sharingLocation,
                    onChanged: cubit.setLocationSharing),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text, {this.onRetry});
  final String text;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(liveRegion: true, child: Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(text), if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente'))],
      )),
    )),
  );
}

// Usa o destino de indisponibilidade do próprio app até existirem essas telas.
class _PendingNavigation implements DriverHomeNavigation {
  const _PendingNavigation(this.context);
  final BuildContext context;
  void _open(String title) => openComingSoonPage(context,
    title: title, message: AppLocalizations.of(context)!.comingSoon);
  @override
  void openShortcut(Shortcut shortcut) => _open(switch (shortcut) {
    Shortcut.students => 'Alunos', Shortcut.route => 'Rota e paradas',
    Shortcut.absences => 'Ausências e ajustes', Shortcut.financial => 'Financeiro',
    Shortcut.assistants => 'Auxiliares', Shortcut.documents => 'Documentos',
  });
  @override
  void openRegularization() => _open('Regularização');
  @override
  void correctAndResubmit() => openShortcut(Shortcut.documents);
  @override
  void openChecklist(String tripId) => _open('Checklist');
  @override
  void callContact(String tripId) => _open('Contato da parada');
}
