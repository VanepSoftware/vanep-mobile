import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_greeting_header.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';

const hoursLeftThreshold = 48;

const rateStarsCount = 5;

String signatureDeadlineLabel(
  AppLocalizations l10n,
  DateTime signBy,
  DateTime now,
) {
  final hoursLeft = signBy.difference(now).inHours;
  if (hoursLeft < hoursLeftThreshold) {
    return l10n.clientHomeHoursLeft(hoursLeft.clamp(0, hoursLeftThreshold));
  }
  return l10n.clientHomeUntilDate(formatDayMonth(signBy));
}

String tripLabel(AppLocalizations l10n, {required bool roundTrip}) =>
    roundTrip ? l10n.clientHomeRoundTrip : l10n.clientHomeOneWay;

class NeedsYouSection extends StatelessWidget {
  const NeedsYouSection({
    required this.summary,
    required this.now,
    required this.onProposalsTapped,
    super.key,
  });

  final NeedsYouSummary summary;
  final DateTime now;
  final VoidCallback onProposalsTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final featured = summary.featured;
    final rows = summary.rows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: l10n.clientHomeNeedsYouTitle,
          actionLabel: summary.hasMore ? l10n.clientHomeSeeAll : null,
          onAction: () =>
              openUnavailableFeature(context, l10n.clientHomeNeedsYouTitle),
        ),
        if (featured is ContractToSignItem)
          ContractToSignCard(item: featured, now: now),
        if (featured is NewProposalItem)
          FeaturedProposalCard(
            item: featured,
            now: now,
            onSeeProposalTapped: onProposalsTapped,
          ),
        if (featured != null && rows.isNotEmpty)
          const SizedBox(height: homeCardSpacing),
        if (rows.isNotEmpty)
          HomeRowsCard(
            rows: [
              for (final item in rows)
                NeedsYouRow(
                  item: item,
                  now: now,
                  onProposalsTapped: onProposalsTapped,
                ),
            ],
          ),
      ],
    );
  }
}

class ContractToSignCard extends StatelessWidget {
  const ContractToSignCard({required this.item, required this.now, super.key});

  final ContractToSignItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      highlighted: true,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeIconBubble(icon: Icons.draw_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.clientHomeContractReady(item.childName),
                      style: VanepTypography.cardTitle,
                    ),
                    Text(
                      l10n.clientHomeDriverAndMonthlyFee(
                        item.driverName,
                        formatMoney(l10n, item.monthlyFeeCents),
                      ),
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
              HomeBadgeText(
                text: signatureDeadlineLabel(l10n, item.signBy, now),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ContractStepsIndicator(
            labels: [
              l10n.clientHomeContractStepAccepted,
              l10n.clientHomeContractStepYou,
              l10n.clientHomeContractStepDriver,
              l10n.clientHomeContractStepStart,
            ],
            currentIndex: 1,
          ),
          const SizedBox(height: 14),
          VanepPrimaryButton(
            label: l10n.clientHomeReviewAndSign,
            onPressed: () => openUnavailableFeature(
              context,
              l10n.clientHomeShortcutContracts,
            ),
          ),
        ],
      ),
    );
  }
}

class ContractStepsIndicator extends StatelessWidget {
  const ContractStepsIndicator({
    required this.labels,
    required this.currentIndex,
    super.key,
  });

  final List<String> labels;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, label) in labels.indexed)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : index <= currentIndex
                            ? VanepColors.action
                            : VanepColors.divider,
                      ),
                    ),
                    Icon(
                      index < currentIndex
                          ? Icons.circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: index <= currentIndex
                          ? VanepColors.action
                          : VanepColors.textMuted,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == labels.length - 1
                            ? Colors.transparent
                            : index < currentIndex
                            ? VanepColors.action
                            : VanepColors.divider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: VanepTypography.cardSubtitle.copyWith(
                    fontSize: 12,
                    color: index == currentIndex
                        ? VanepColors.textPrimary
                        : VanepColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class FeaturedProposalCard extends StatelessWidget {
  const FeaturedProposalCard({
    required this.item,
    required this.now,
    required this.onSeeProposalTapped,
    super.key,
  });

  final NewProposalItem item;
  final DateTime now;
  final VoidCallback onSeeProposalTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      highlighted: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.clientHomeNewProposal,
                  style: VanepTypography.linkAction.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              HomeBadgeText(
                text: l10n.clientHomeExpiresIn(
                  calendarDaysBetween(now, item.expiresAt),
                ),
                color: VanepColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              VanepPersonAvatar(name: item.driverName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.driverName, style: VanepTypography.cardTitle),
                    Text(
                      l10n.clientHomeNamesAndTrip(
                        joinNames(l10n, item.childNames),
                        tripLabel(l10n, roundTrip: item.roundTrip),
                      ),
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: formatMoney(l10n, item.monthlyFeeCents),
                      style: VanepTypography.heading.copyWith(fontSize: 18),
                    ),
                    TextSpan(
                      text: l10n.clientHomePerMonth,
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientHomeChat,
                  icon: Icons.chat_bubble_outline,
                  onPressed: () =>
                      openUnavailableFeature(context, l10n.clientHomeChat),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VanepPrimaryButton(
                  label: l10n.clientHomeSeeProposal,
                  onPressed: onSeeProposalTapped,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NeedsYouRow extends StatelessWidget {
  const NeedsYouRow({
    required this.item,
    required this.now,
    required this.onProposalsTapped,
    super.key,
  });

  final NeedsYouItem item;
  final DateTime now;
  final VoidCallback onProposalsTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = this.item;

    return switch (item) {
      ContractToSignItem() => HomeRowTile(
        leading: const HomeIconBubble(icon: Icons.draw_outlined),
        title: l10n.clientHomeContractReady(item.childName),
        subtitle: l10n.clientHomeDriverAndMonthlyFee(
          item.driverName,
          formatMoney(l10n, item.monthlyFeeCents),
        ),
        trailing: HomeBadgeText(
          text: signatureDeadlineLabel(l10n, item.signBy, now),
        ),
        onTap: () =>
            openUnavailableFeature(context, l10n.clientHomeShortcutContracts),
      ),
      NewProposalItem() => HomeRowTile(
        leading: VanepPersonAvatar(name: item.driverName),
        title: l10n.clientHomeNewProposalFor(joinNames(l10n, item.childNames)),
        subtitle: l10n.clientHomeDriverAndMonthlyFee(
          item.driverName,
          formatMoney(l10n, item.monthlyFeeCents),
        ),
        onTap: onProposalsTapped,
      ),
      ExpiredRequestItem() => HomeRowTile(
        leading: VanepPersonAvatar(name: item.driverName),
        title: l10n.clientHomeRequestExpired(firstNameOf(item.driverName)),
        subtitle: l10n.clientHomeSeeSimilarDrivers,
        onTap: () =>
            openUnavailableFeature(context, l10n.clientHomeSeeSimilarDrivers),
      ),
      PaymentItem() => PaymentRow(item: item, now: now),
      RenewalItem() => HomeRowTile(
        leading: const HomeIconBubble(icon: Icons.autorenew),
        title: l10n.clientHomeRenewalFor('${item.year}'),
        subtitle: l10n.clientHomeDriverSentProposal(item.driverName),
        onTap: () =>
            openUnavailableFeature(context, l10n.clientHomeShortcutContracts),
      ),
      VehicleInspectionExpiredItem() => HomeRowTile(
        leading: const HomeIconBubble(
          icon: Icons.assignment_late_outlined,
          background: VanepColors.warningSurface,
          foreground: VanepColors.warning,
        ),
        title: l10n.clientHomeInspectionExpired,
        subtitle: l10n.clientHomeInspectionDeadline(
          item.driverName,
          formatDayMonth(item.regularizeBy),
        ),
        onTap: () =>
            openUnavailableFeature(context, l10n.clientHomeInspectionExpired),
      ),
      RateDriverItem() => HomeRowTile(
        leading: VanepPersonAvatar(name: item.driverName),
        title: l10n.clientHomeRateVan(firstNameOf(item.driverName)),
        subtitle: l10n.clientHomeRatingIsAnonymous,
        footer: RateStars(driverName: item.driverName),
      ),
    };
  }
}

class PaymentRow extends StatelessWidget {
  const PaymentRow({required this.item, required this.now, super.key});

  final PaymentItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amount = formatMoney(l10n, item.amountCents);
    final confirmingDriver = item.awaitingConfirmationFrom;
    final childName = item.childName;
    final daysLeft = calendarDaysBetween(now, item.dueAt);

    return HomeRowTile(
      leading: const HomeIconBubble(
        icon: Icons.payments_outlined,
        background: VanepColors.warningSurface,
        foreground: VanepColors.warning,
      ),
      title: childName != null
          ? l10n.clientHomeMonthlyFeeOf(childName)
          : l10n.clientHomeMonthlyFeeFor(formatMonthName(l10n, item.dueAt)),
      subtitle: confirmingDriver != null
          ? l10n.clientHomeAwaitingConfirmation(amount, confirmingDriver)
          : amount,
      trailing: confirmingDriver != null
          ? null
          : HomeBadgeText(
              text: daysLeft < 0
                  ? l10n.clientHomeOverdue
                  : l10n.clientHomeDueIn(daysLeft),
              color: daysLeft < 0 ? VanepColors.danger : VanepColors.warning,
            ),
      onTap: () =>
          openUnavailableFeature(context, l10n.clientHomeShortcutPayments),
    );
  }
}

class RateStars extends StatelessWidget {
  const RateStars({required this.driverName, super.key});

  final String driverName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var stars = 1; stars <= rateStarsCount; stars++)
            IconButton(
              tooltip: l10n.clientHomeRateStars(stars),
              onPressed: () => openUnavailableFeature(
                context,
                l10n.clientHomeRateVan(firstNameOf(driverName)),
              ),
              icon: const Icon(
                Icons.star_border_rounded,
                color: VanepColors.textMuted,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}
