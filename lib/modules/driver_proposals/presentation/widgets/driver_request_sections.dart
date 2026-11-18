import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/formatters/calendar_date_formatter.dart';
import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/driver_proposals_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/item_groups.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class DriverClientCard extends StatelessWidget {
  const DriverClientCard({
    required this.request,
    this.subtitle,
    this.onChat,
    super.key,
  });

  final DriverServiceRequest request;
  final String? subtitle;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onChat = this.onChat;
    return VanepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalPersonHeader(
            avatar: VanepPersonAvatar(name: request.clientFirstName),
            name: request.clientFirstName,
            subtitle: subtitle,
          ),
          if (onChat != null) ...[
            const SizedBox(height: 12),
            VanepSecondaryButton(
              label: l10n.clientProposalsChat,
              icon: Icons.chat_bubble_outline,
              onPressed: onChat,
            ),
          ],
        ],
      ),
    );
  }
}

class DriverStudentsSection extends StatelessWidget {
  const DriverStudentsSection({required this.request, super.key});

  final DriverServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DetailSection(
      title: l10n.proposalDetailStudentsTitle(request.items.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in request.items) ...[
            Text(item.dependentFirstName, style: context.typography.cardTitle),
            Text(
              formatDriverStudentDetail(l10n, item),
              style: context.typography.cardSubtitle,
            ),
            if (item != request.items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class DriverRouteSection extends StatelessWidget {
  const DriverRouteSection({required this.request, super.key});

  final DriverServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showsNames = request.items.length > 1;
    return DetailSection(
      title: l10n.quoteRequestRouteTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in request.items) ...[
            if (showsNames)
              Text(
                item.dependentFirstName,
                style: context.typography.fieldLabel,
              ),
            if (item.pickupNeighborhood case final neighborhood?)
              DetailInfoRow(
                label: l10n.quoteRequestPickup,
                values: [neighborhood],
              ),
            if (item.schoolName case final school?)
              DetailInfoRow(
                label: l10n.quoteRequestDestination,
                values: [school],
              ),
          ],
          const SizedBox(height: 6),
          DetailNotice(
            icon: Icons.lock_outline,
            text: l10n.driverRequestAddressNotice,
          ),
        ],
      ),
    );
  }
}

class DriverRequestedDaysSection extends StatelessWidget {
  const DriverRequestedDaysSection({required this.request, super.key});

  final DriverServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DetailWeekLegsSection(
      gridsByChildren: [
        for (final group in groupItemsByDays(request.items))
          (
            joinNames(l10n, [
              for (final item in group) item.dependentFirstName,
            ]),
            weekLegsRowsOfDays(l10n, group.first.days),
          ),
      ],
    );
  }
}

class DriverRequestTermsCard extends StatelessWidget {
  const DriverRequestTermsCard({required this.request, super.key});

  final DriverServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          DetailInfoRow(
            label: l10n.proposalDetailDesiredStart,
            values: [formatCalendarDate(l10n, request.desiredStartDate)],
          ),
          DetailInfoRow(
            label: l10n.proposalDetailAnswerBy,
            values: [formatDayMonthAndTime(l10n, request.expiresAt)],
          ),
        ],
      ),
    );
  }
}
