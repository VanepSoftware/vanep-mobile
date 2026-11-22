import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
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
    HomePhase.underReview || HomePhase.rejected => DriverUnderReviewCompanion(
      navigation: navigation,
    ),
    HomePhase.buildingRoute => const DriverBuildingRouteCompanion(),
    HomePhase.beforeDeparture => DriverBeforeDepartureCompanion(
      data: data,
      rules: rules,
      navigation: navigation,
    ),
    HomePhase.inProgress => DriverInProgressCompanion(navigation: navigation),
    HomePhase.shiftCompleted => DriverShiftCompletedCompanion(
      navigation: navigation,
    ),
    HomePhase.noRouteToday => DriverNoRouteTodayCompanion(
      data: data,
      rules: rules,
      navigation: navigation,
    ),
    HomePhase.blocked => DriverBlockedCompanion(navigation: navigation),
  };
}

// TODO(VAN-66): Replace static "Preço a partir de R$ 320/mês" row with live driver onboarding
// checklist status once the driver profile readiness endpoint is integrated.
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
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.sell_outlined,
                backgroundColor: DriverHomeTokens.successSoft,
                iconColor: DriverHomeTokens.success,
              ),
              title: l10n.driverHomeAdvancePriceTitle,
              subtitle: l10n.driverHomeAdvancePriceHint,
              trailing: Text(
                l10n.driverHomeDoneBadge,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.success,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// TODO(VAN-66): Wire "Aceitando novos alunos" switch and "Solicitações" empty state to
// VanCentralCubit attendance and DriverNegotiationsCubit once DriverHome aggregates them.
class DriverBuildingRouteCompanion extends StatefulWidget {
  const DriverBuildingRouteCompanion({super.key});

  @override
  State<DriverBuildingRouteCompanion> createState() =>
      DriverBuildingRouteCompanionState();
}

class DriverBuildingRouteCompanionState
    extends State<DriverBuildingRouteCompanion> {
  bool acceptingNewStudents = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: DriverHomeTokens.surface,
            borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
            border: Border.all(color: DriverHomeTokens.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driverHomeAcceptingNewStudents,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DriverHomeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.driverHomeAcceptingNewStudentsHint,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: acceptingNewStudents,
                onChanged: (value) =>
                    setState(() => acceptingNewStudents = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeRequestsTitle),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: DriverHomeTokens.surface,
            borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
            border: Border.all(color: DriverHomeTokens.border),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F4F7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  color: DriverHomeTokens.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.driverHomeRequestsEmptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: DriverHomeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.driverHomeRequestsEmptySubtitle,
                textAlign: TextAlign.center,
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
    );
  }
}

// TODO(VAN-66): Replace static pre-departure feed items (Pedro stop request, Ana/Lucas absences,
// Maria Oliveira contract, afternoon route summary) with live items from the driver home feed endpoint.
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
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeBeforeDepartureSection),
        const SizedBox(height: 10),
        DriverListCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const DriverIconBubble(
                        icon: Icons.edit_location_alt_outlined,
                        backgroundColor: DriverHomeTokens.actionSoft,
                        iconColor: DriverHomeTokens.action,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.driverHomeStopRequestTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: DriverHomeTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.driverHomeStopRequestSubtitle,
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
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DriverHomeTokens.textPrimary,
                              side: const BorderSide(
                                color: DriverHomeTokens.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () =>
                                navigation.openShortcut(Shortcut.absences),
                            child: Text(
                              l10n.driverHomeDecline,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: DriverHomeTokens.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DriverHomeTokens.action,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () =>
                                navigation.openShortcut(Shortcut.absences),
                            child: Text(
                              l10n.driverHomeApprove,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.event_busy_outlined,
                backgroundColor: DriverHomeTokens.warningSoft,
                iconColor: DriverHomeTokens.warning,
              ),
              title: l10n.driverHomeAbsencesTodayTitle,
              subtitle: l10n.driverHomeAbsencesTodaySubtitle,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: DriverHomeTokens.textMuted,
              ),
              onTap: () => navigation.openShortcut(Shortcut.absences),
            ),
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.draw_outlined,
                backgroundColor: Color(0xFFF1F4F7),
                iconColor: DriverHomeTokens.textPrimary,
              ),
              title: l10n.driverHomeContractToSignTitle,
              subtitle: l10n.driverHomeContractToSignSubtitle,
              trailing: Text(
                l10n.driverHomeContractHoursLeft,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.warning,
                ),
              ),
              onTap: () => navigation.openShortcut(Shortcut.documents),
            ),
          ],
        ),
        if (familyCounter != null) ...[
          const SizedBox(height: 14),
          DriverFamilyProgressCard(
            count: familyCounter,
            total: data.studentCount,
            onInviteTap: () => navigation.openShortcut(Shortcut.students),
          ),
        ],
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
            title: l10n.driverHomeLaterAfternoonRouteTitle,
            subtitle: l10n.driverHomeLaterAfternoonRouteSubtitle,
            onTap: () => navigation.openShortcut(Shortcut.route),
          ),
        ),
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

// TODO(VAN-66): Replace static recent check-offs (Pedro, Helena/Davi, Laura) with the live
// trip events log once the active trip timeline endpoint is integrated.
class DriverInProgressCompanion extends StatelessWidget {
  const DriverInProgressCompanion({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

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
        const SizedBox(height: 20),
        DriverSectionHeader(
          title: l10n.driverHomeRecentCheckoffsTitle,
          trailingText: l10n.driverHomeFullListAction,
          onTrailingTap: () => navigation.openShortcut(Shortcut.route),
        ),
        const SizedBox(height: 10),
        DriverListCard(
          children: [
            DriverListRow(
              leading: const DriverInitialAvatar(
                initial: 'P',
                backgroundColor: DriverHomeTokens.actionSoft,
                textColor: DriverHomeTokens.action,
              ),
              title: l10n.driverHomeCheckoff1Title,
              subtitle: l10n.driverHomeCheckoff1Subtitle,
              trailing: Text(
                l10n.driverHomeCheckoffNotified,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.success,
                ),
              ),
            ),
            DriverListRow(
              leading: const DriverInitialAvatar(
                initial: 'H',
                backgroundColor: DriverHomeTokens.successSoft,
                textColor: DriverHomeTokens.success,
              ),
              title: l10n.driverHomeCheckoff2Title,
              subtitle: l10n.driverHomeCheckoff2Subtitle,
              trailing: Text(
                l10n.driverHomeCheckoffNotified,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.success,
                ),
              ),
            ),
            DriverListRow(
              leading: const DriverInitialAvatar(
                initial: 'L',
                backgroundColor: Color(0xFFF1F4F7),
                textColor: DriverHomeTokens.textSecondary,
              ),
              title: l10n.driverHomeCheckoff3Title,
              subtitle: l10n.driverHomeCheckoff3Subtitle,
              trailing: Text(
                l10n.driverHomeCheckoffFix,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.action,
                ),
              ),
              onTap: () => navigation.openShortcut(Shortcut.route),
            ),
          ],
        ),
      ],
    );
  }
}

class DriverInitialAvatar extends StatelessWidget {
  const DriverInitialAvatar({
    required this.initial,
    required this.backgroundColor,
    required this.textColor,
    super.key,
  });

  final String initial;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
    child: Text(
      initial,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    ),
  );
}

// TODO(VAN-66): Replace static next shift details ("11h50 · 12 alunos · 9 paradas") and
// break tasks (quote requests, contract signature, 2027 renewal) with live backend items.
class DriverShiftCompletedCompanion extends StatelessWidget {
  const DriverShiftCompletedCompanion({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DriverHomeTokens.surface,
            borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
            border: Border.all(color: DriverHomeTokens.border),
          ),
          child: Row(
            children: [
              const DriverIconBubble(
                icon: Icons.wb_sunny_outlined,
                backgroundColor: DriverHomeTokens.warningSoft,
                iconColor: DriverHomeTokens.warning,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driverHomeNextShiftOverline.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.66,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.driverHomeNextShiftAfternoonTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: DriverHomeTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.driverHomeNextShiftAfternoonSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: DriverHomeTokens.textPrimary,
                  side: const BorderSide(color: DriverHomeTokens.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => navigation.openShortcut(Shortcut.route),
                child: Text(
                  l10n.driverHomeListAction,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DriverHomeTokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeUseBreakSection),
        const SizedBox(height: 10),
        DriverListCard(
          children: [
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.request_quote_outlined,
                backgroundColor: DriverHomeTokens.actionSoft,
                iconColor: DriverHomeTokens.action,
              ),
              title: l10n.driverHomeQuoteRequestsTitle,
              subtitle: l10n.driverHomeQuoteRequestsSubtitle,
              trailing: Text(
                l10n.driverHomeQuoteRequestsWait,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DriverHomeTokens.textSecondary,
                ),
              ),
              onTap: () => navigation.openShortcut(Shortcut.students),
            ),
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.draw_outlined,
                backgroundColor: Color(0xFFF1F4F7),
                iconColor: DriverHomeTokens.textPrimary,
              ),
              title: l10n.driverHomeContractToSignTitle,
              subtitle: l10n.driverHomeContractToSignSubtitle,
              trailing: Text(
                l10n.driverHomeContractHoursLeft,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DriverHomeTokens.warning,
                ),
              ),
              onTap: () => navigation.openShortcut(Shortcut.documents),
            ),
            DriverListRow(
              leading: const DriverIconBubble(
                icon: Icons.autorenew,
                backgroundColor: Color(0xFFF1F4F7),
                iconColor: DriverHomeTokens.textPrimary,
              ),
              title: l10n.driverHomeRenewalTitle,
              subtitle: l10n.driverHomeRenewalSubtitle,
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: DriverHomeTokens.textMuted,
              ),
              onTap: () => navigation.openShortcut(Shortcut.financial),
            ),
          ],
        ),
      ],
    );
  }
}

// TODO(VAN-66): Replace static business panel metrics (Sprinter 16 seats occupancy, 19 active
// contracts / R$ 8.400/mês, R$ 49,90 subscription, semiannual inspection due in 12 days)
// with live business dashboard data once backend endpoints are integrated.
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
    final missingFamilies = familyCounter == null
        ? 0
        : (data.studentCount - familyCounter).clamp(0, data.studentCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        DriverSectionHeader(title: l10n.driverHomeYourBusinessSection),
        const SizedBox(height: 10),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.driverHomeSprinterSeatsTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: DriverHomeTokens.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.driverHomeSprinterSeatsTotal,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: DriverHomeTokens.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DriverOccupancyMeterRow(
                shiftLabel: l10n.driverHomeMorning,
                used: 16,
                capacity: 16,
                statusText: l10n.driverHomeMorningFull,
                statusColor: DriverHomeTokens.warning,
              ),
              const SizedBox(height: 12),
              DriverOccupancyMeterRow(
                shiftLabel: l10n.driverHomeAfternoon,
                used: 12,
                capacity: 16,
                statusText: l10n.driverHomeAfternoonVacancies,
                statusColor: DriverHomeTokens.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DriverHomeTokens.surface,
                  borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
                  border: Border.all(color: DriverHomeTokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driverHomeActiveContractsLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '19',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: DriverHomeTokens.textPrimary,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.driverHomeActiveContractsRevenue,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DriverHomeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (familyCounter != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DriverHomeTokens.surface,
                    borderRadius: BorderRadius.circular(
                      DriverHomeTokens.radiusMd,
                    ),
                    border: Border.all(color: DriverHomeTokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverHomeStudentsWithFamilyLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DriverHomeTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.driverHomeFamilyCounter(
                          familyCounter,
                          data.studentCount,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DriverHomeTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => navigation.openShortcut(Shortcut.students),
                        child: Text(
                          missingFamilies > 0
                              ? l10n.driverHomeInviteCount(missingFamilies)
                              : l10n.driverHomeInviteAction,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DriverHomeTokens.action,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        DriverSectionHeader(
          title: l10n.driverHomeSubscriptionSection,
          trailingText: l10n.driverHomeSubscriptionDue,
        ),
        const SizedBox(height: 10),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.driverHomeMonthlyPlan,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DriverHomeTokens.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.driverHomeMonthlyPlanPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: DriverHomeTokens.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.driverHomeMonthlyPlanHint,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: DriverHomeTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              VanepPrimaryButton(
                label: l10n.driverHomePayWithPix,
                onPressed: () => navigation.openShortcut(Shortcut.financial),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: DriverHomeTokens.surface,
            borderRadius: BorderRadius.circular(DriverHomeTokens.radiusMd),
            border: Border.all(color: DriverHomeTokens.border),
          ),
          child: DriverListRow(
            leading: const DriverIconBubble(
              icon: Icons.assignment_late_outlined,
              backgroundColor: DriverHomeTokens.warningSoft,
              iconColor: DriverHomeTokens.warning,
            ),
            title: l10n.driverHomeInspectionWarningTitle,
            subtitle: l10n.driverHomeInspectionWarningSubtitle,
            trailing: const Icon(
              Icons.chevron_right,
              size: 20,
              color: DriverHomeTokens.textMuted,
            ),
            onTap: () => navigation.openShortcut(Shortcut.documents),
          ),
        ),
      ],
    );
  }
}

class DriverOccupancyMeterRow extends StatelessWidget {
  const DriverOccupancyMeterRow({
    required this.shiftLabel,
    required this.used,
    required this.capacity,
    required this.statusText,
    required this.statusColor,
    super.key,
  });

  final String shiftLabel;
  final int used;
  final int capacity;
  final String statusText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ratio = capacity > 0 ? (used / capacity).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              shiftLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DriverHomeTokens.textPrimary,
              ),
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: DriverHomeTokens.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: '$used ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: DriverHomeTokens.textPrimary,
                    ),
                  ),
                  TextSpan(text: '${l10n.driverHomeOfTotal(capacity)} · '),
                  TextSpan(
                    text: statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: const Color(0xFFEDF0F3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              DriverHomeTokens.brand,
            ),
          ),
        ),
      ],
    );
  }
}

// TODO(VAN-66): Replace static expired CRLV ("08/11") and afternoon route ("11h50 · 12 alunos")
// with live compliance and schedule items from the driver regularization endpoint.
class DriverBlockedCompanion extends StatelessWidget {
  const DriverBlockedCompanion({required this.navigation, super.key});

  final DriverHomeNavigation navigation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                          l10n.driverHomeExpiredCrlvTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: DriverHomeTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.driverHomeExpiredCrlvSubtitle,
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
                label: l10n.driverHomeSendNewCrlv,
                icon: Icons.upload_file_outlined,
                onPressed: () => navigation.openShortcut(Shortcut.documents),
              ),
            ],
          ),
        ),
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
              backgroundColor: DriverHomeTokens.warningSoft,
              iconColor: DriverHomeTokens.warning,
            ),
            title: l10n.driverHomeNextShiftAfternoonTitle,
            subtitle: l10n.driverHomeAfternoonRouteStudents,
            trailing: Text(
              l10n.driverHomeReleasedBadge,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DriverHomeTokens.success,
              ),
            ),
          ),
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
