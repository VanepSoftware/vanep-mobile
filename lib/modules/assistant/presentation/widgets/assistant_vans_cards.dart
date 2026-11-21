import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

const minimumTouchTarget = 44.0;

List<(Color, Color)> vanIconTonesOf(VanepPalette palette) => [
  (palette.actionSurface, palette.action),
  (palette.successSurface, palette.success),
];

// TODO(VAN-68): Detalhes (VAN-69) and Vínculos anteriores (VAN-69) do
// nothing until those screens exist. Wire each call site and delete this
// function.
void doNothingYet() {}

class AssistantPendingInviteCard extends StatelessWidget {
  const AssistantPendingInviteCard({
    required this.invite,
    required this.daysLeft,
    this.onAccept = doNothingYet,
    this.onReject = doNothingYet,
    super.key,
  });

  final AssistantInvite invite;

  final int daysLeft;

  final VoidCallback onAccept;

  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expiry = daysLeft < 1
        ? l10n.assistantVansExpiresToday
        : l10n.assistantVansExpiresInDays(daysLeft);

    return Semantics(
      container: true,
      label: '${invite.driverName}, ${invite.vehicleDescription ?? ''}, $expiry',
      child: VanepCard(
        highlighted: true,
        child: Column(
          children: [
            Row(
              children: [
                VanepAvatar(
                  size: 40,
                  initials: assistantInitialsOf(invite.driverName),
                  backgroundColor: context.palette.warningSurface,
                  foregroundColor: context.palette.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite.driverName,
                        style: context.typography.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (invite.vehicleDescription != null)
                        Text(
                          invite.vehicleDescription!,
                          style: context.typography.cardSubtitle,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(expiry, style: context.typography.ratingLabel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.assistantVansDecline,
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VanepPrimaryButton(
                    label: l10n.assistantVansAccept,
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AssistantVanCard extends StatelessWidget {
  const AssistantVanCard({
    required this.summary,
    required this.toneIndex,
    this.onOpenDetails = doNothingYet,
    this.onOpenRoute = doNothingYet,
    super.key,
  });

  final AssistantVanSummary summary;

  final int toneIndex;

  final VoidCallback onOpenDetails;

  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final van = summary.van;
    final tones = vanIconTonesOf(context.palette);
    final (surface, accent) = tones[toneIndex % tones.length];
    final title = l10n.assistantVansVanTitle(firstNameOf(van.driverName));
    final subtitle = assistantVanSubtitle(l10n, van);
    final departure = l10n.assistantVansDeparture(
      formatDepartureTime(
        summary.departureMinutes,
        languageCode: Localizations.localeOf(context).languageCode,
      ),
    );
    final students = l10n.assistantVansStudentCount(summary.studentCount);

    return Semantics(
      container: true,
      label: '$title, $subtitle, $departure, $students',
      child: VanepCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.airport_shuttle_rounded,
                    color: accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.typography.cardTitle),
                      const SizedBox(height: 2),
                      Text(subtitle, style: context.typography.cardSubtitle),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: context.palette.divider),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: context.palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(departure, style: context.typography.cardSubtitle),
                const SizedBox(width: 16),
                Icon(
                  Icons.groups_rounded,
                  size: 18,
                  color: context.palette.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(students, style: context.typography.cardSubtitle),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.assistantVansDetails,
                    onPressed: onOpenDetails,
                  ),
                ),
                if (summary.hasRouteToday) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: VanepPrimaryButton(
                      label: l10n.assistantVansRouteToday,
                      onPressed: onOpenRoute,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AssistantFormerVansTile extends StatelessWidget {
  const AssistantFormerVansTile({
    required this.count,
    this.onTap = doNothingYet,
    super.key,
  });

  final int count;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = l10n.assistantVansFormerLinks(count);

    return Semantics(
      button: true,
      label: label,
      child: VanepCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: minimumTouchTarget + 12,
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 22,
                color: context.palette.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: context.typography.ratingLabel)),
              Icon(
                Icons.chevron_right_rounded,
                color: context.palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
