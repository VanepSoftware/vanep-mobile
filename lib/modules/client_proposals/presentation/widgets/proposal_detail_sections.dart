import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/formatters/proposal_detail_labels.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposals_building_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
            Text(item.dependentName, style: context.typography.cardTitle),
            Text(
              formatClientStudentDetail(l10n, item, today),
              style: context.typography.cardSubtitle,
            ),
            if (item != request.items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
