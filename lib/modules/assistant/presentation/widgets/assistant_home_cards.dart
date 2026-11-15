import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_choice_chips.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_home_labels.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

const assistantHomeSectionSpacing = 24.0;
const assistantHomeItemSpacing = 12.0;

class AssistantVanChips extends StatelessWidget {
  const AssistantVanChips({
    required this.links,
    required this.selectedVanToken,
    required this.onSelected,
    super.key,
  });

  final List<AssistantVanLink> links;
  final String selectedVanToken;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepChoiceChips<String>(
      choices: [
        for (final link in links)
          VanepChoice(
            value: link.van.token,
            label: [
              firstNameOf(link.van.driverName),
              assistantVansShiftLabel(l10n, link.van.shift),
            ].where((part) => part.isNotEmpty).join(vanSubtitleSeparator),
          ),
      ],
      selected: selectedVanToken,
      onSelected: onSelected,
    );
  }
}

class AssistantNoVanCard extends StatelessWidget {
  const AssistantNoVanCard({
    required this.onCopyEmail,
    required this.onShareEmail,
    this.email,
    super.key,
  });

  final String? email;
  final VoidCallback onCopyEmail;
  final VoidCallback onShareEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;
    final address = email;

    return VanepCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.assistantHomeNoVanTitle, style: typography.overline),
          const SizedBox(height: 6),
          Text(l10n.assistantHomeNoVanBody, style: typography.cardTitle),
          const SizedBox(height: 4),
          Text(l10n.assistantHomeNoVanHint, style: typography.cardSubtitle),
          if (address != null) ...[
            const SizedBox(height: assistantHomeItemSpacing),
            Row(
              children: [
                Icon(Icons.mail_outline, color: context.palette.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(address, style: typography.fieldValue)),
                IconButton(
                  tooltip: l10n.assistantHomeCopyEmail,
                  onPressed: onCopyEmail,
                  icon: const Icon(Icons.content_copy),
                ),
              ],
            ),
            const SizedBox(height: assistantHomeItemSpacing),
            VanepPrimaryButton(
              label: l10n.assistantHomeShareEmail,
              trailingIcon: Icons.share,
              onPressed: onShareEmail,
            ),
          ],
        ],
      ),
    );
  }
}

class AssistantNumberedSteps extends StatelessWidget {
  const AssistantNumberedSteps({
    required this.title,
    required this.steps,
    super.key,
  });

  final String title;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.sectionTitle),
        const SizedBox(height: assistantHomeItemSpacing),
        for (final (index, step) in steps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: palette.actionSurface,
                  child: Text(
                    '${index + 1}',
                    style: context.typography.ratingLabel.copyWith(
                      color: palette.action,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(step, style: context.typography.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class AssistantCapabilitiesList extends StatelessWidget {
  const AssistantCapabilitiesList({
    required this.title,
    required this.capabilities,
    required this.restriction,
    required this.restrictionIcon,
    super.key,
  });

  AssistantCapabilitiesList.ofApp(AppLocalizations l10n, {super.key})
    : title = l10n.assistantHomeCapabilitiesTitle,
      capabilities = [
        l10n.assistantHomeCapabilityRoute,
        l10n.assistantHomeCapabilityConfirm,
        l10n.assistantHomeCapabilityNoShow,
      ],
      restriction = l10n.assistantHomeCapabilityHidden,
      restrictionIcon = Icons.visibility_off;

  final String title;
  final List<String> capabilities;
  final String restriction;
  final IconData restrictionIcon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final rows = [
      for (final capability in capabilities)
        (Icons.check_circle, palette.success, capability),
      (restrictionIcon, palette.textMuted, restriction),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.sectionTitle),
        const SizedBox(height: assistantHomeItemSpacing),
        for (final (icon, color, label) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: context.typography.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class AssistantBeforeRouteCard extends StatelessWidget {
  const AssistantBeforeRouteCard({
    required this.link,
    required this.isPresentInVan,
    required this.onPresentInVan,
    this.route,
    super.key,
  });

  final AssistantVanLink link;
  final AssistantRouteSnapshot? route;
  final bool isPresentInVan;
  final VoidCallback onPresentInVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;
    final palette = context.palette;
    final languageCode = Localizations.localeOf(context).languageCode;
    final today = route;
    final departure = today?.departureAt;

    return VanepCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.assistantHomeTodayOutbound,
                  style: typography.overline,
                ),
              ),
              VanepChip(
                label: today == null
                    ? l10n.assistantHomeNoTripToday
                    : l10n.assistantHomeNotStarted,
                background: palette.warningSurface,
                foreground: palette.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (departure != null)
            Text(
              l10n.assistantVansDeparture(
                formatClockTime(departure, languageCode: languageCode),
              ),
              style: typography.pageTitle,
            ),
          Text(assistantHomeVanLabel(l10n, link.van), style: typography.body),
          if (today != null) ...[
            const SizedBox(height: assistantHomeItemSpacing),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  l10n.assistantHomeStudentsCount(
                    today.expectedPassengerCountOf(TripLeg.outbound),
                  ),
                  style: typography.cardSubtitle,
                ),
                Text(
                  l10n.assistantHomeStopsCount(
                    today.stopCountOf(TripLeg.outbound),
                  ),
                  style: typography.cardSubtitle,
                ),
                Text(
                  l10n.assistantHomeAbsencesCount(today.todayAbsences.length),
                  style: typography.cardSubtitle,
                ),
              ],
            ),
            const SizedBox(height: assistantHomeItemSpacing),
            if (isPresentInVan)
              VanepChip(
                label: l10n.assistantHomePresentConfirmed,
                icon: Icons.how_to_reg,
                background: palette.successSurface,
                foreground: palette.success,
              )
            else
              VanepSecondaryButton(
                label: l10n.assistantHomePresentInVan,
                onPressed: onPresentInVan,
              ),
            const SizedBox(height: 8),
            Text(
              l10n.assistantHomeChecklistOpensHint,
              style: typography.cardSubtitle,
            ),
          ],
        ],
      ),
    );
  }
}

class AssistantPausedCard extends StatelessWidget {
  const AssistantPausedCard({
    required this.link,
    required this.otherActiveLinks,
    required this.onSelectVan,
    super.key,
  });

  final AssistantVanLink link;
  final List<AssistantVanLink> otherActiveLinks;
  final ValueChanged<String> onSelectVan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.typography;
    final palette = context.palette;
    final driver = firstNameOf(link.van.driverName);
    final pausedAt = link.statusChangedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepCard(
          borderColor: palette.warningBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.pause_circle, color: palette.warning, size: 32),
              const SizedBox(height: 8),
              if (pausedAt != null)
                Text(
                  l10n.assistantHomePausedTitle(formatDayAndMonth(pausedAt)),
                  style: typography.overline,
                ),
              Text(
                l10n.assistantHomePausedBy(driver),
                style: typography.cardTitle,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.assistantHomePausedBody,
                style: typography.cardSubtitle,
              ),
              const SizedBox(height: assistantHomeItemSpacing),
              // TODO(VAN-67): the driver phone is not exposed to the
              // assistant yet (backend B6); enable once it is.
              VanepSecondaryButton(
                label: l10n.assistantHomeCallDriverNamed(driver),
                onPressed: null,
              ),
            ],
          ),
        ),
        for (final other in otherActiveLinks) ...[
          const SizedBox(height: assistantHomeSectionSpacing),
          Text(l10n.assistantHomeOtherVan, style: typography.sectionTitle),
          const SizedBox(height: assistantHomeItemSpacing),
          VanepCard(
            onTap: () => onSelectVan(other.van.token),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assistantHomeVanLabel(l10n, other.van),
                        style: typography.cardTitle,
                      ),
                      Text(
                        l10n.assistantHomeSeeOtherVanRoute,
                        style: typography.linkAction,
                      ),
                    ],
                  ),
                ),
                VanepChip(
                  label: l10n.assistantHomeActive,
                  background: palette.successSurface,
                  foreground: palette.success,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: assistantHomeItemSpacing),
        Text(l10n.assistantHomePausedInfo, style: typography.cardSubtitle),
      ],
    );
  }
}
