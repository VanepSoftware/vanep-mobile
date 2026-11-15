import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/formatters/installments_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/domain/calendar_days.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_expiry_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_installment_price.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_negotiation_actions.dart';
import 'package:vanep_mobile/modules/client_home/presentation/formatters/client_home_labels.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_building_blocks.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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

class NeedsYouSection extends StatelessWidget {
  const NeedsYouSection({
    required this.summary,
    required this.now,
    required this.actions,
    super.key,
  });

  final NeedsYouSummary summary;
  final DateTime now;
  final HomeNegotiationActions actions;

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
          FeaturedProposalCard(item: featured, now: now, actions: actions),
        if (featured != null && rows.isNotEmpty)
          const SizedBox(height: homeCardSpacing),
        if (rows.isNotEmpty)
          HomeRowsCard(
            rows: [
              for (final item in rows)
                NeedsYouRow(item: item, now: now, actions: actions),
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
                      style: context.typography.cardTitle,
                    ),
                    Text(
                      l10n.clientHomeDriverAndMonthlyFee(
                        item.driverName,
                        formatMoney(l10n, item.monthlyFeeCents),
                      ),
                      style: context.typography.cardSubtitle,
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
                            ? context.palette.action
                            : context.palette.divider,
                      ),
                    ),
                    Icon(
                      index < currentIndex
                          ? Icons.circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: index <= currentIndex
                          ? context.palette.action
                          : context.palette.textMuted,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == labels.length - 1
                            ? Colors.transparent
                            : index < currentIndex
                            ? context.palette.action
                            : context.palette.divider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: context.typography.cardSubtitle.copyWith(
                    fontSize: 12,
                    color: index == currentIndex
                        ? context.palette.textPrimary
                        : context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

TextStyle featuredPriceStyle(VanepPalette palette) => TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: palette.textPrimary,
  fontFeatures: [FontFeature.tabularFigures()],
);

TextStyle featuredInstallmentsStyle(VanepPalette palette) => TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: palette.textSecondary,
);

class FeaturedProposalCard extends StatelessWidget {
  const FeaturedProposalCard({
    required this.item,
    required this.now,
    required this.actions,
    super.key,
  });

  final NewProposalItem item;
  final DateTime now;
  final HomeNegotiationActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expiresAt = item.expiresAt;
    final request = item.request;
    return VanepCard(
      borderColor: context.palette.actionBorder,
      onTap: () => actions.onProposalTapped(request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.clientHomeNewProposal.toUpperCase(),
                  style: context.typography.overline,
                ),
              ),
              if (expiresAt != null)
                VanepExpiryChip(
                  label: l10n.clientHomeExpiresIn(
                    calendarDaysBetween(now, expiresAt.toLocal()),
                  ),
                  isUrgent: isExpiryUrgent(now, expiresAt),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              VanepPersonAvatar(name: item.driverName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.driverName,
                      style: context.typography.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      joinFirstNames(l10n, item.childNames),
                      style: context.typography.cardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              VanepInstallmentPrice(
                amountCents: item.installmentAmountCents,
                installments: item.installments,
                amountStyle: featuredPriceStyle(context.palette),
                countStyle: featuredInstallmentsStyle(context.palette),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (request.conversationToken != null) ...[
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.clientHomeChat,
                    icon: Icons.chat_bubble_outline,
                    onPressed: () => actions.onChatTapped(request),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: VanepPrimaryButton(
                  label: l10n.clientHomeSeeProposal,
                  onPressed: () => actions.onProposalTapped(request),
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
    required this.actions,
    super.key,
  });

  final NeedsYouItem item;
  final DateTime now;
  final HomeNegotiationActions actions;

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
        title: l10n.clientHomeNewProposalFor(
          joinFirstNames(l10n, item.childNames),
        ),
        subtitle: l10n.clientHomeDriverAndInstallments(
          item.driverName,
          formatInstallments(
            l10n,
            item.installments,
            item.installmentAmountCents,
          ),
        ),
        onTap: () => actions.onProposalTapped(item.request),
      ),
      ExpiredRequestItem() => HomeRowTile(
        leading: VanepPersonAvatar(name: item.driverName),
        title: l10n.clientHomeRequestExpired(firstNameOf(item.driverName)),
        subtitle: l10n.clientHomeSearchVans,
        onTap: actions.onFindVanTapped,
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
        leading: HomeIconBubble(
          icon: Icons.assignment_late_outlined,
          background: context.palette.warningSurface,
          foreground: context.palette.warning,
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
      leading: HomeIconBubble(
        icon: Icons.payments_outlined,
        background: context.palette.warningSurface,
        foreground: context.palette.warning,
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
              color: daysLeft < 0
                  ? context.palette.danger
                  : context.palette.warning,
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
              icon: Icon(
                Icons.star_border_rounded,
                color: context.palette.textMuted,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}
