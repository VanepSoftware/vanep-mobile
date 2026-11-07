import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/formatters/weekday_label.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_expiry_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';
import 'package:vanep_mobile/core/ui/vanep_current_dot.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/proposal_detail_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/item_groups.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/leg_times.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_history.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_comparison.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';

const detailSectionSpacing = 16.0;

const scheduleLegIconSize = 40.0;

const historyRailWidth = 14.0;

const proposalPriceStyle = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  letterSpacing: -0.8,
  height: 1.1,
  color: VanepColors.textPrimary,
  fontFeatures: [FontFeature.tabularFigures()],
);

const proposalInstallmentsSuffixStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  color: VanepColors.textSecondary,
);

const historyConnectorWidth = 2.0;

const scheduleTimeStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: VanepColors.textPrimary,
  fontFeatures: [FontFeature.tabularFigures()],
);

List<VanepWeekLegsRow<RouteLeg>> weekLegsRowsOfSlots(
  AppLocalizations l10n,
  List<ScheduleSlot> slots,
) {
  return [
    for (final leg in RouteLeg.values)
      VanepWeekLegsRow(
        leg: leg,
        label: routeLegLabel(l10n, leg),
        cells: {
          for (final slot in slots)
            if (slot.leg == leg)
              slot.weekday: const VanepWeekLegCell(isSelected: true),
        },
      ),
  ];
}

List<VanepWeekLegsRow<RouteLeg>> weekLegsRowsOfDays(
  AppLocalizations l10n,
  List<RequestedDay> days,
) {
  return [
    for (final leg in RouteLeg.values)
      VanepWeekLegsRow(
        leg: leg,
        label: routeLegLabel(l10n, leg),
        cells: {
          for (final day in days)
            day.weekday: VanepWeekLegCell(
              isSelected: leg == RouteLeg.outbound
                  ? day.needsOutbound
                  : day.needsReturn,
            ),
        },
      ),
  ];
}

class DetailSection extends StatelessWidget {
  const DetailSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProposalsSectionTitle(title: title),
        VanepCard(child: child),
      ],
    );
  }
}

class DetailInfoRow extends StatelessWidget {
  const DetailInfoRow({required this.label, required this.values, super.key});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: VanepTypography.cardSubtitle),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final value in values)
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: VanepTypography.cardSubtitle.copyWith(
                      color: VanepColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailNotice extends StatelessWidget {
  const DetailNotice({
    required this.text,
    this.icon = Icons.info_outline,
    super.key,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: VanepColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: VanepTypography.cardSubtitle)),
      ],
    );
  }
}

class DetailDriverCard extends StatelessWidget {
  const DetailDriverCard({required this.request, this.proposal, super.key});

  final ClientServiceRequest request;
  final Proposal? proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = proposal?.vehicle;
    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalDriverHeader(request: request),
          if (vehicle != null) ...[
            const SizedBox(height: 10),
            DetailNotice(
              icon: Icons.airport_shuttle_outlined,
              text: formatProposalVehicle(l10n, vehicle),
            ),
          ],
        ],
      ),
    );
  }
}

class ProposalValueCard extends StatelessWidget {
  const ProposalValueCard({
    required this.proposal,
    required this.today,
    this.previousVersion,
    this.onCompare,
    super.key,
  });

  final Proposal proposal;
  final DateTime today;
  final Proposal? previousVersion;
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previous = previousVersion;

    return VanepCard(
      padding: previous == null
          ? const EdgeInsets.all(16)
          : const EdgeInsets.fromLTRB(16, 16, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.proposalDetailVersion(proposal.version).toUpperCase(),
                  style: VanepTypography.overline,
                ),
              ),
              VanepExpiryChip(
                label: l10n.proposalDetailExpiresOn(
                  formatDayAndMonth(l10n, proposal.validUntil),
                ),
                isUrgent: isExpiryUrgent(today, proposal.validUntil),
              ),
            ],
          ),
          const SizedBox(height: 12),
          VanepInstallmentPrice(
            amountCents: proposal.installmentAmountCents,
            installments: proposal.installments,
            amountStyle: proposalPriceStyle,
            countStyle: proposalInstallmentsSuffixStyle,
          ),
          const SizedBox(height: 2),
          Text(
            l10n.proposalDetailTotal(
              formatMoney(l10n, proposal.totalAmountCents),
            ),
            style: VanepTypography.cardSubtitle,
          ),
          if (previous != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: VanepColors.divider),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PriceChangeSummary(
                        change: comparePrices(previous, proposal),
                      ),
                    ),
                  ),
                ),
                ProposalLinkButton(
                  label: l10n.proposalDetailCompare,
                  leadingIcon: Icons.compare_arrows,
                  onPressed: onCompare,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class PriceChangeSummary extends StatelessWidget {
  const PriceChangeSummary({required this.change, super.key});

  final PriceChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (change.isEmpty) return const SizedBox.shrink();
    final amount = formatMoney(l10n, change.totalDifferenceCents.abs());
    final totalColor = change.isCheaper
        ? VanepColors.success
        : VanepColors.textSecondary;
    final installmentsStyle = VanepTypography.cardSubtitle.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Semantics(
      label: [
        if (change.hasTotalChanged)
          change.isCheaper
              ? l10n.proposalDetailCheaperBy(amount)
              : l10n.proposalDetailPricierBy(amount),
        if (change.hasInstallmentsChanged)
          l10n.proposalDetailInstallmentsChanged(
            change.previousInstallments,
            change.currentInstallments,
          ),
      ].join(', '),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (change.hasTotalChanged) ...[
            Icon(
              change.isCheaper ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: totalColor,
            ),
            const SizedBox(width: 4),
            Text(
              amount,
              style: VanepTypography.cardSubtitle.copyWith(
                fontWeight: FontWeight.w700,
                color: totalColor,
              ),
            ),
          ],
          if (change.hasTotalChanged && change.hasInstallmentsChanged)
            Text(' · ', style: VanepTypography.cardSubtitle),
          if (change.hasInstallmentsChanged) ...[
            Text(
              l10n.installmentsCount(change.previousInstallments),
              style: installmentsStyle,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward,
                size: 14,
                color: VanepColors.textMuted,
              ),
            ),
            Text(
              l10n.installmentsCount(change.currentInstallments),
              style: installmentsStyle,
            ),
          ],
        ],
      ),
    );
  }
}

class DetailStudentsSection extends StatelessWidget {
  const DetailStudentsSection({
    required this.request,
    required this.today,
    super.key,
  });

  final ClientServiceRequest request;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DetailSection(
      title: l10n.proposalDetailStudentsTitle(request.items.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in request.items) ...[
            Text(item.dependentName, style: VanepTypography.cardTitle),
            Text(
              formatStudentDetail(l10n, item, today),
              style: VanepTypography.cardSubtitle,
            ),
            if (item != request.items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class DetailWeekLegsSection extends StatelessWidget {
  const DetailWeekLegsSection({required this.gridsByChildren, super.key});

  final List<(String, List<VanepWeekLegsRow<RouteLeg>>)> gridsByChildren;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showsNames = gridsByChildren.length > 1;
    return DetailSection(
      title: l10n.proposalDetailDaysTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, (names, rows)) in gridsByChildren.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            if (showsNames) Text(names, style: VanepTypography.fieldLabel),
            VanepWeekLegsGrid<RouteLeg>(rows: rows),
          ],
        ],
      ),
    );
  }
}

class DetailScheduleSection extends StatelessWidget {
  const DetailScheduleSection({
    required this.proposal,
    required this.request,
    super.key,
  });

  final Proposal proposal;
  final ClientServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = groupItemsBySchedule(proposal.items);
    final showsNames = groups.length > 1;
    final tiles = <Widget>[
      for (final group in groups) ...[
        if (showsNames)
          Text(
            joinNames(l10n, [
              for (final item in group) item.dependentFirstName,
            ]),
            style: VanepTypography.fieldLabel,
          ),
        for (final leg in RouteLeg.values)
          if (timesOfLeg(group.first.slots, leg) case final times
              when !times.isEmpty)
            ScheduleLegTile(leg: leg, times: times),
      ],
    ];
    return DetailSection(
      title: l10n.proposalDetailScheduleTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, tile) in tiles.indexed) ...[
            if (index > 0)
              tile is ScheduleLegTile
                  ? const Divider(height: 24, color: VanepColors.divider)
                  : const SizedBox(height: 16),
            tile,
          ],
        ],
      ),
    );
  }
}

class ScheduleLegTile extends StatelessWidget {
  const ScheduleLegTile({required this.leg, required this.times, super.key});

  final RouteLeg leg;
  final LegTimes times;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shared = times.shared;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: scheduleLegIconSize,
          height: scheduleLegIconSize,
          decoration: const BoxDecoration(
            color: VanepColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            leg == RouteLeg.outbound
                ? Icons.home_outlined
                : Icons.school_outlined,
            size: 20,
            color: VanepColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routeLegLabel(l10n, leg),
                          style: VanepTypography.cardTitle,
                        ),
                        Text(
                          leg == RouteLeg.outbound
                              ? l10n.proposalDetailPickupAtHome
                              : l10n.proposalDetailLeaveSchool,
                          style: VanepTypography.cardSubtitle,
                        ),
                      ],
                    ),
                  ),
                  if (shared != null)
                    Text(formatClockTime(shared), style: scheduleTimeStyle),
                ],
              ),
              if (shared == null)
                for (final MapEntry(key: weekday, value: time)
                    in times.byDay.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: MergeSemantics(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              weekdayShortLabel(l10n, weekday),
                              style: VanepTypography.cardSubtitle,
                            ),
                          ),
                          Text(formatClockTime(time), style: scheduleTimeStyle),
                        ],
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

class DetailConditionsSection extends StatelessWidget {
  const DetailConditionsSection({required this.proposal, super.key});

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fee = proposal.enrollmentFeeCents;
    return DetailSection(
      title: l10n.proposalDetailConditionsTitle,
      child: Column(
        children: [
          DetailInfoRow(
            label: l10n.proposalDetailPeriod,
            values: [formatProposalPeriod(l10n, proposal)],
          ),
          DetailInfoRow(
            label: l10n.proposalDetailDueDay,
            values: [l10n.proposalDetailDueDayValue(proposal.dueDay)],
          ),
          if (fee != null)
            DetailInfoRow(
              label: l10n.proposalDetailEnrollmentFee,
              values: [formatMoney(l10n, fee)],
            ),
          DetailInfoRow(
            label: l10n.proposalDetailAdjustment,
            values: [adjustmentPolicyLabel(l10n, proposal.adjustmentPolicy)],
          ),
          DetailInfoRow(
            label: l10n.proposalDetailCancellation,
            values: [
              cancellationPolicyLabel(l10n, proposal.cancellationPolicy),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailTextSection extends StatelessWidget {
  const DetailTextSection({required this.title, required this.text, super.key});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      title: title,
      child: Text(
        text,
        style: VanepTypography.body.copyWith(color: VanepColors.textPrimary),
      ),
    );
  }
}

class NegotiationHistorySection extends StatelessWidget {
  const NegotiationHistorySection({required this.events, super.key});

  final List<NegotiationEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DetailSection(
      title: l10n.proposalDetailHistoryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, event) in events.indexed)
            NegotiationHistoryEntry(
              title: negotiationEventTitle(l10n, event),
              date: formatDayMonthAndTime(l10n, event.at),
              isCurrent: event is ProposalSentEvent && event.isOpen,
              showsConnector: index < events.length - 1,
            ),
        ],
      ),
    );
  }
}

class NegotiationHistoryEntry extends StatelessWidget {
  const NegotiationHistoryEntry({
    required this.title,
    required this.date,
    this.isCurrent = false,
    this.showsConnector = false,
    super.key,
  });

  final String title;
  final String date;
  final bool isCurrent;
  final bool showsConnector;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: historyRailWidth,
            child: Column(
              children: [
                const SizedBox(height: 5),
                VanepCurrentDot(
                  isCurrent: isCurrent,
                  semanticLabel: l10n.negotiationHistoryCurrent,
                ),
                if (showsConnector)
                  Expanded(
                    child: Container(
                      width: historyConnectorWidth,
                      margin: const EdgeInsets.only(top: 4),
                      color: VanepColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showsConnector ? 14 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: VanepTypography.cardSubtitle.copyWith(
                        color: VanepColors.textPrimary,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(date, style: VanepTypography.cardSubtitle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
