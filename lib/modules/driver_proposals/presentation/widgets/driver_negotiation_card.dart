import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/formatters/driver_proposals_labels.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/formatters/negotiation_labels.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';

class DriverNegotiationCard extends StatelessWidget {
  const DriverNegotiationCard({
    required this.request,
    required this.now,
    required this.onTap,
    super.key,
  });

  final DriverServiceRequest request;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deadline = formatDriverTurnDeadline(l10n, request, now);
    final startsOn =
        request.currentProposal?.startsOn ?? request.desiredStartDate;

    return VanepCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProposalPersonHeader(
            avatar: VanepPersonAvatar(name: request.clientFirstName),
            name: formatClientAndChildren(l10n, request),
            subtitle: formatDriverTurnTitle(l10n, request),
            trailing: deadline == null
                ? null
                : ProposalStatusText(text: deadline),
          ),
          const SizedBox(height: 12),
          ProposalTermsBox(
            lines: [
              for (final school in formatRequestSchools(l10n, request))
                (Icons.school_outlined, school),
              for (final pickup in formatPickupNeighborhoods(l10n, request))
                (Icons.location_on_outlined, pickup),
              (
                Icons.event_repeat_outlined,
                formatRequestedDaysAndStart(l10n, request, startsOn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
