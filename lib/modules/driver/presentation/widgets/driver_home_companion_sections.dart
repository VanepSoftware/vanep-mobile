import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
import 'package:vanep_mobile/modules/driver/presentation/driver_home_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';

class DriverHomeCompanionSections extends StatelessWidget {
  const DriverHomeCompanionSections({
    required this.phase,
    required this.data,
    required this.rules,
    required this.navigation,
    super.key,
  });

  final HomePhase phase;
  final DriverHomeData data;
  final DriverHomeRules rules;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) => switch (phase) {
    HomePhase.incomplete => const SizedBox.shrink(),
    HomePhase.underReview ||
    HomePhase.rejected => DriverUnderReviewCompanion(navigation: navigation),
    // TODO(VAN-66): Add the "accepting new students" toggle and pending requests once
    // DriverHome aggregates VanCentralCubit attendance and DriverNegotiationsCubit.
    HomePhase.buildingRoute => const SizedBox.shrink(),
    HomePhase.beforeDeparture => DriverBeforeDepartureCompanion(
      data: data,
      rules: rules,
      navigation: navigation,
    ),
    HomePhase.inProgress => const DriverInProgressCompanion(),
    // TODO(VAN-66): Add break tasks (quote requests, contracts to sign, renewals) once the
    // driver home feed endpoint returns them. The next shift is shown on the main card.
    HomePhase.shiftCompleted => const SizedBox.shrink(),
    HomePhase.noRouteToday => DriverNoRouteTodayCompanion(
      data: data,
      rules: rules,
      navigation: navigation,
    ),
    HomePhase.blocked => DriverBlockedCompanion(
      data: data,
      navigation: navigation,
    ),
  };
}

// TODO(VAN-66): Add the "starting price" row once the driver profile readiness endpoint
// exposes the configured price.
class DriverUnderReviewCompanion extends StatelessWidget {
  const DriverUnderReviewCompanion({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeMeanwhileAdvanceRoute),
        const SizedBox(height: 10),
        DriverListCard(
          children: [
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.person_add_alt_1_outlined,
                backgroundColor: DriverHomeTokens.warningSoft,
                iconColor: DriverHomeTokens.warning,
              ),
              title: l10n.driverHomeAdvanceStudentsTitle,
              subtitle: l10n.driverHomeAdvanceStudentsHint,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: DriverHomeTokens.textMuted,
              ),
              onTap: () => navigation.openShortcut(Shortcut.students),
            ),
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.badge_outlined,
                backgroundColor: Color(0xFFF1F4F7),
                iconColor: DriverHomeTokens.textPrimary,
              ),
              title: l10n.driverHomeAdvanceAssistantTitle,
              subtitle: l10n.driverHomeAdvanceAssistantHint,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: DriverHomeTokens.textMuted,
              ),
              onTap: () => navigation.openShortcut(Shortcut.assistants),
            ),
          ],
        ),
      ],
    );
  }
}

// TODO(VAN-66): Add pre-departure feed items (stop change requests, absences, contracts to
// sign) once the driver home feed endpoint returns them.
class DriverBeforeDepartureCompanion extends StatelessWidget {
  const DriverBeforeDepartureCompanion({
    required this.data,
    required this.rules,
    required this.navigation,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeRules rules;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // D12: Contador "X de Y com família no app" aparece até 100% quando conhecido.
    final familyCounter = rules.familyCounter(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (familyCounter != null) ...[
          const SizedBox(height: 14),
          DriverFamilyProgressCard(
            count: familyCounter,
            total: data.studentCount,
            onInviteTap: () => navigation.openShortcut(Shortcut.students),
          ),
        ],
        if (data.laterShiftLabel != null) ...[
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: DriverHomeTokens.surface,
              borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
              border: Border.all(color: DriverHomeTokens.border),
            ),
            child: DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.wb_sunny_outlined,
                backgroundColor: Color(0xFFF1F4F7),
                iconColor: DriverHomeTokens.textSecondary,
              ),
              title: l10n.driverHomeNextShift(
                localizeDriverShift(l10n, data.laterShiftLabel!),
              ),
              onTap: () => navigation.openShortcut(Shortcut.route),
            ),
          ),
        ],
      ],
    );
  }
}

class DriverFamilyProgressCard extends StatelessWidget {
  const DriverFamilyProgressCard({
    required this.count,
    required this.total,
    required this.onInviteTap,
    super.key,
  });

  final int count;
  final int total;
  final VoidCallback onInviteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final missing = (total - count).clamp(0, total);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverHomeTokens.surface,
        borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
        border: Border.all(color: DriverHomeTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.driverHomeFamilyCounter(count, total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DriverHomeTokens.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: onInviteTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.driverHomeInviteAction,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DriverHomeTokens.action,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: DriverHomeTokens.action,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDF0F3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                DriverHomeTokens.action,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            missing > 0
                ? l10n.driverHomeMissingFamiliesHint(missing)
                : l10n.driverHomeAllFamiliesInAppHint,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: DriverHomeTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// TODO(VAN-66): Add recent check-offs once the active trip timeline endpoint is integrated.
class DriverInProgressCompanion extends StatelessWidget {
  const DriverInProgressCompanion({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: DriverHomeTokens.warningSoft,
            borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
            border: Border.all(color: const Color(0xFFF3D9B1)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.pan_tool_outlined,
                color: DriverHomeTokens.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.driverHomeDrivingNotice,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A4506),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// TODO(VAN-66): Add business metrics (seat occupancy, active contracts, revenue), the Vanep
// subscription and inspection reminders once the driver business dashboard endpoints exist.
class DriverNoRouteTodayCompanion extends StatelessWidget {
  const DriverNoRouteTodayCompanion({
    required this.data,
    required this.rules,
    required this.navigation,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeRules rules;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // D12: Contador "X de Y com família no app" aparece até 100% quando conhecido.
    final familyCounter = rules.familyCounter(data);
    if (familyCounter == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeYourBusinessSection),
        const SizedBox(height: 10),
        DriverFamilyProgressCard(
          count: familyCounter,
          total: data.studentCount,
          onInviteTap: () => navigation.openShortcut(Shortcut.students),
        ),
      ],
    );
  }
}

// TODO(VAN-66): Show which document expired and its due date once the driver regularization
// endpoint returns them.
class DriverBlockedCompanion extends StatelessWidget {
  const DriverBlockedCompanion({
    required this.data,
    required this.navigation,
    super.key,
  });

  final DriverHomeData data;
  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.expiredDocument) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DriverHomeTokens.surface,
              borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
              border: Border.all(color: DriverHomeTokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DriverIconBubble(
                      icon: Icons.description_outlined,
                      backgroundColor: DriverHomeTokens.dangerSoft,
                      iconColor: DriverHomeTokens.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.driverHomeExpiredDocumentTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: DriverHomeTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.driverHomeExpiredDocumentSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: DriverHomeTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                VanepSecondaryButton(
                  label: l10n.driverHomeSendNewDocument,
                  icon: Icons.upload_file_outlined,
                  onPressed: () => navigation.openShortcut(Shortcut.documents),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeMeanwhileSection),
        const SizedBox(height: 10),
        DriverListCard(
          children: [
            DriverCapabilityStatusRow(
              allowed: true,
              label: l10n.driverHomeMeanwhileRoutes,
            ),
            DriverCapabilityStatusRow(
              allowed: true,
              label: l10n.driverHomeMeanwhileContracts,
            ),
            DriverCapabilityStatusRow(
              allowed: false,
              label: l10n.driverHomeMeanwhileProposals,
            ),
            DriverCapabilityStatusRow(
              allowed: false,
              label: l10n.driverHomeMeanwhileSearch,
            ),
          ],
        ),
      ],
    );
  }
}

class DriverCapabilityStatusRow extends StatelessWidget {
  const DriverCapabilityStatusRow({
    required this.allowed,
    required this.label,
    super.key,
  });

  final bool allowed;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Icon(
          allowed ? Icons.check_circle_outline : Icons.block,
          size: 20,
          color: allowed ? DriverHomeTokens.success : DriverHomeTokens.danger,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DriverHomeTokens.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

class DriverEndRouteFooter extends StatelessWidget {
  const DriverEndRouteFooter({required this.onEndRoute, super.key});

  final VoidCallback onEndRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DriverHomeTokens.danger,
              side: const BorderSide(color: Color(0xFFEFC9C3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onEndRoute,
            icon: const Icon(
              Icons.stop_circle_outlined,
              color: DriverHomeTokens.danger,
              size: 20,
            ),
            label: Text(
              l10n.driverHomeEndRouteAction,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: DriverHomeTokens.danger,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.driverHomeEndRouteHint,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DriverHomeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
