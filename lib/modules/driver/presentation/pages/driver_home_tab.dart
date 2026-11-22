import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_greeting_header.dart';
import 'package:vanep_mobile/core/ui/vanep_home_top_bar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_state.dart';
import 'package:vanep_mobile/modules/driver/presentation/driver_home_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_companion_sections.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';

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
  State<DriverHomeTab> createState() => DriverHomeTabState();
}

class DriverHomeTabState extends State<DriverHomeTab> {
  @override
  void initState() {
    super.initState();
    context.read<DriverHomeCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<DriverHomeCubit>();
    final navigation = widget.navigation ?? PendingDriverHomeNavigation(context);
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
                DriverHomeGreetingSection(
                  displayName: widget.displayName,
                  shiftStartTime: state.shiftStartTime,
                  phase: resolved?.phase,
                ),
                const SizedBox(height: 14),
                if (state.loading || state.busy)
                  const LinearProgressIndicator(),
                if (state.error case final DriverHomeMessage error)
                  DriverHomeNoticeBanner(
                    error.localize(l10n),
                    onRetry: cubit.refresh,
                  ),
                if (resolved?.blockBanner case final DriverHomeMessage banner)
                  DriverHomeNoticeBanner(banner.localize(l10n)),
                if (data != null && resolved != null) ...[
                  if (data.outsideWorkingHours)
                    DriverHomeNoticeBanner(l10n.driverHomeOutsideHours),
                  DriverHomeMainCard(
                    data: data,
                    phase: resolved.phase,
                    navigation: navigation,
                    enabled: !state.busy && !state.loading,
                    sharingLocation: state.sharingLocation,
                    onLocationSharingChanged: cubit.setLocationSharing,
                    onStartRoute: cubit.startRoute,
                    onConfirmStop: cubit.confirmBySlide,
                  ),
                  DriverHomeCompanionSections(
                    phase: resolved.phase,
                    data: data,
                    rules: cubit.rules,
                    navigation: navigation,
                  ),
                  const SizedBox(height: 20),
                  DriverHomeShortcuts(
                    data: data,
                    rules: cubit.rules,
                    onOpen: navigation.openShortcut,
                  ),
                  if (resolved.phase == HomePhase.inProgress)
                    DriverEndRouteFooter(
                      onEndRoute: () => navigation.openShortcut(Shortcut.route),
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

class DriverHomeGreetingSection extends StatelessWidget {
  const DriverHomeGreetingSection({
    required this.displayName,
    required this.shiftStartTime,
    required this.phase,
    super.key,
  });

  final String displayName;
  final String shiftStartTime;
  final HomePhase? phase;

  String extractFirstName() {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (shiftStartTime.isNotEmpty || phase == null) {
      return VanepGreetingHeader(
        displayName: displayName,
        subtitle: shiftStartTime.isEmpty
            ? null
            : l10n.driverShiftStartsAt(shiftStartTime),
      );
    }
    final firstName = extractFirstName();
    final (title, subtitle, showVerifiedIcon) = switch (phase!) {
      HomePhase.incomplete => (
        l10n.driverHomeGreetingHello(firstName),
        l10n.driverHomeSubtitleIncomplete,
        false,
      ),
      HomePhase.underReview => (
        l10n.driverHomeGreetingHello(firstName),
        l10n.driverHomeSubtitleUnderReview,
        false,
      ),
      HomePhase.rejected => (
        l10n.driverHomeGreetingHello(firstName),
        l10n.driverHomeSubtitleRejected,
        false,
      ),
      HomePhase.buildingRoute => (
        l10n.driverHomeGreetingHello(firstName),
        l10n.driverHomeSubtitleBuildingRoute,
        true,
      ),
      HomePhase.beforeDeparture => (
        l10n.driverHomeGreetingMorning(firstName),
        l10n.driverHomeSubtitleBeforeDeparture,
        false,
      ),
      HomePhase.inProgress => (
        l10n.driverHomeInProgress,
        l10n.driverHomeSubtitleInProgress,
        false,
      ),
      HomePhase.shiftCompleted => (
        l10n.driverHomeGreetingMorningCompleted,
        l10n.driverHomeSubtitleShiftCompleted(firstName),
        false,
      ),
      HomePhase.noRouteToday => (
        l10n.driverHomeGreetingSaturday(firstName),
        l10n.driverHomeSubtitleNoRouteToday,
        false,
      ),
      HomePhase.blocked => (
        l10n.driverHomeGreetingHelloPlain(firstName),
        l10n.driverHomeSubtitleBlocked,
        false,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: DriverHomeTokens.textPrimary,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (showVerifiedIcon) ...[
              const Icon(
                Icons.verified,
                size: 16,
                color: DriverHomeTokens.success,
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DriverHomeTokens.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DriverHomeNoticeBanner extends StatelessWidget {
  const DriverHomeNoticeBanner(this.text, {this.onRetry, super.key});

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
class PendingDriverHomeNavigation implements DriverHomeNavigation {
  const PendingDriverHomeNavigation(this.context);

  final BuildContext context;

  void openPage(String title) => openComingSoonPage(
    context,
    title: title,
    message: AppLocalizations.of(context)!.comingSoon,
  );

  @override
  void openShortcut(Shortcut shortcut) => openPage(switch (shortcut) {
    Shortcut.students => AppLocalizations.of(context)!.driverHomeStudents,
    Shortcut.route => AppLocalizations.of(context)!.driverHomeRoute,
    Shortcut.absences => AppLocalizations.of(context)!.driverHomeAbsences,
    Shortcut.financial => AppLocalizations.of(context)!.driverHomeFinancial,
    Shortcut.assistants => AppLocalizations.of(context)!.driverHomeAssistants,
    Shortcut.documents =>
      AppLocalizations.of(context)!.driverHomeDocumentsShortcut,
  });

  @override
  void openRegularization() =>
      openPage(AppLocalizations.of(context)!.driverHomeRegularization);

  @override
  void correctAndResubmit() => openShortcut(Shortcut.documents);

  @override
  void openChecklist(String tripId) =>
      openPage(AppLocalizations.of(context)!.driverHomeChecklist);

  @override
  void callContact(String tripId) =>
      openPage(AppLocalizations.of(context)!.driverHomeContact);
}
