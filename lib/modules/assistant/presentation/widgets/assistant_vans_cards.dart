import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';
import 'package:vanep_mobile/modules/assistant/presentation/formatters/assistant_vans_labels.dart';

const minimumTouchTarget = 44.0;

const vanIconTones = [
  (VanepColors.actionSurface, VanepColors.action),
  (VanepColors.successSurface, VanepColors.success),
];

// TODO(VAN-68): the buttons of these cards do nothing until the screens they
// open exist: Detalhes -> VAN-69, Rota de hoje -> VAN-71, Aceitar and Recusar
// -> invite accept/reject (already in AssistantRemoteDataSource), Vínculos
// anteriores -> no task yet. Replace each call site and delete this function.
void doNothingYet() {}

class AssistantPendingInviteCard extends StatelessWidget {
  const AssistantPendingInviteCard({
    required this.invite,
    required this.daysLeft,
    super.key,
  });

  final AssistantInvite invite;

  final int daysLeft;

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
                  backgroundColor: VanepColors.warningSurface,
                  foregroundColor: VanepColors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite.driverName,
                        style: VanepTypography.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (invite.vehicleDescription != null)
                        Text(
                          invite.vehicleDescription!,
                          style: VanepTypography.cardSubtitle,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(expiry, style: VanepTypography.ratingLabel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.assistantVansDecline,
                    onPressed: doNothingYet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VanepPrimaryButton(
                    label: l10n.assistantVansAccept,
                    onPressed: doNothingYet,
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
    super.key,
  });

  final AssistantVanSummary summary;

  final int toneIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final van = summary.van;
    final (surface, accent) = vanIconTones[toneIndex % vanIconTones.length];
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
                      Text(title, style: VanepTypography.cardTitle),
                      const SizedBox(height: 2),
                      Text(subtitle, style: VanepTypography.cardSubtitle),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: VanepColors.divider),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: VanepColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(departure, style: VanepTypography.cardSubtitle),
                const SizedBox(width: 16),
                const Icon(
                  Icons.groups_rounded,
                  size: 18,
                  color: VanepColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(students, style: VanepTypography.cardSubtitle),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: VanepSecondaryButton(
                    label: l10n.assistantVansDetails,
                    onPressed: doNothingYet,
                  ),
                ),
                if (summary.hasRouteToday) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: VanepPrimaryButton(
                      label: l10n.assistantVansRouteToday,
                      onPressed: doNothingYet,
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
  const AssistantFormerVansTile({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = l10n.assistantVansFormerLinks(count);

    return Semantics(
      button: true,
      label: label,
      child: VanepCard(
        onTap: doNothingYet,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: minimumTouchTarget + 12,
          child: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 22,
                color: VanepColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: VanepTypography.ratingLabel)),
              const Icon(
                Icons.chevron_right_rounded,
                color: VanepColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
