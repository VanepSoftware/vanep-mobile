import 'package:vanep_mobile/modules/driver/presentation/driver_home_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_greeting_header.dart';
import 'package:vanep_mobile/core/ui/vanep_home_top_bar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_location_sharing_tile.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_shift_badge.dart';

class DriverHomeTab extends StatefulWidget {
  const DriverHomeTab({
    required this.displayName,
    required this.onMenuTapped,
    required this.onNotificationsTapped,
    this.navigation,
    super.key,
  });
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
                VanepHomeTopBar(
                  onMenuTapped: widget.onMenuTapped,
                  onNotificationsTapped: widget.onNotificationsTapped,
                ),
                const SizedBox(height: 8),
                VanepGreetingHeader(
                  displayName: widget.displayName,
                  subtitle: state.shiftStartTime.isEmpty
                      ? null
                      : l10n.driverShiftStartsAt(state.shiftStartTime),
                ),
                const SizedBox(height: 14),
                if (state.loading || state.busy)
                  const LinearProgressIndicator(),
                if (state.error case final DriverHomeMessage error)
                  _Notice(error.localize(l10n), onRetry: cubit.refresh),
                if (resolved?.blockBanner case final DriverHomeMessage banner)
                  _Notice(banner.localize(l10n)),
                if (data != null && resolved != null) ...[
                  DriverShiftBadge(onShift: state.onShift),
                  const SizedBox(height: 20),
                  // Fora do expediente apenas avisa, sem bloquear o card.
                  if (data.outsideWorkingHours)
                    _Notice(
                      AppLocalizations.of(context)!.driverHomeOutsideHours,
                    ),
                  DriverHomeMainCard(
                    data: data,
                    phase: resolved.phase,
                    cubit: cubit,
                    navigation: navigation,
                    enabled: !state.busy && !state.loading,
                  ),
                  const SizedBox(height: 20),
                  if (cubit.rules.familyCounter(data) case final int counter)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        l10n.driverHomeFamilyCounter(
                          counter,
                          data.studentCount,
                        ),
                      ),
                    ),
                  DriverHomeShortcuts(
                    data: data,
                    rules: cubit.rules,
                    onOpen: navigation.openShortcut,
                  ),
                  const SizedBox(height: 20),
                  DriverLocationSharingTile(
                    sharing: state.sharingLocation,
                    onChanged: cubit.setLocationSharing,
                  ),
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
    child: Semantics(
      liveRegion: true,
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: Text(AppLocalizations.of(context)!.driverHomeRetry),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

// TODO(VAN-66): Replace pending navigation as destination screens become available;
// DriverShell must inject DriverHomeNavigation for documents, checklist and contact.
class _PendingNavigation implements DriverHomeNavigation {
  const _PendingNavigation(this.context);
  final BuildContext context;
  void _open(String title) => openComingSoonPage(
    context,
    title: title,
    message: AppLocalizations.of(context)!.comingSoon,
  );
  @override
  void openShortcut(Shortcut shortcut) => _open(switch (shortcut) {
    Shortcut.students => AppLocalizations.of(context)!.driverHomeStudents,
    Shortcut.route => AppLocalizations.of(context)!.driverHomeRoute,
    Shortcut.absences => AppLocalizations.of(context)!.driverHomeAbsences,
    Shortcut.financial => AppLocalizations.of(context)!.driverHomeFinancial,
    Shortcut.assistants => AppLocalizations.of(context)!.driverHomeAssistants,
    Shortcut.documents => AppLocalizations.of(
      context,
    )!.driverHomeDocumentsShortcut,
  });
  @override
  void openRegularization() =>
      _open(AppLocalizations.of(context)!.driverHomeRegularization);
  @override
  void correctAndResubmit() => openShortcut(Shortcut.documents);
  @override
  void openChecklist(String tripId) =>
      _open(AppLocalizations.of(context)!.driverHomeChecklist);
  @override
  void callContact(String tripId) =>
      _open(AppLocalizations.of(context)!.driverHomeContact);
}
