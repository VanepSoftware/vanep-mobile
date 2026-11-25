import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';
import 'package:vanep_mobile/core/domain/iso_calendar_date.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/client_proposals_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/proposal_detail_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';

class DetailDriverCard extends StatelessWidget {
  const DetailDriverCard({required this.request, this.proposal, super.key});

  final ClientServiceRequest request;
  final Proposal? proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vehicle = proposal?.vehicle;
    final rating = request.driverRating;
    final ratingText = rating == null ? null : formatProposalRating(l10n, rating);
    final vehicleText = vehicle == null
        ? null
        : formatProposalVehicle(l10n, vehicle);
    final subtitle = [?ratingText, ?vehicleText].join(' · ');

    return VanepCard(
      child: ProposalDriverHeader(
        request: request,
        showVerified: true,
        subtitle: subtitle.isEmpty ? null : subtitle,
        subtitleLeading: rating != null
            ? const Icon(
                Icons.star_rounded,
                size: 15,
                color: VanepColors.ratingStar,
              )
            : null,
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
            _DetailStudentRow(item: item, today: today),
            if (item != request.items.last) const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          DetailNotice(
            icon: Icons.visibility_off_outlined,
            text: l10n.proposalDetailPrivacyNotice,
          ),
        ],
      ),
    );
  }
}

class _DetailStudentRow extends StatelessWidget {
  const _DetailStudentRow({required this.item, required this.today});

  final ClientRequestItem item;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final years = findAgeInYears(item.dependentBirthDate, today: today);
    final title = years == null
        ? item.dependentName
        : '${item.dependentName}, ${l10n.dependentsAgeYears(years)}';
    final subtitle = formatClientStudentDetailWithoutAge(l10n, item);

    return Row(
      children: [
        VanepPersonAvatar(name: item.dependentName, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.typography.cardTitle),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: context.typography.cardSubtitle),
            ],
          ),
        ),
      ],
    );
  }
}
