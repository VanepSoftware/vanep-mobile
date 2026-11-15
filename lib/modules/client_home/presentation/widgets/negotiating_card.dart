import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/formatters/names_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_person_avatar.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class NegotiatingCard extends StatelessWidget {
  const NegotiatingCard({
    required this.section,
    required this.onSearchVansTapped,
    required this.onSeeProposalsTapped,
    super.key,
  });

  final NegotiatingSection section;
  final VoidCallback onSearchVansTapped;

  final VoidCallback onSeeProposalsTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return VanepCard(
      child: Column(
        children: [
          Row(
            children: [
              VanepAvatarStack(names: section.childNames),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.clientHomeNoVanYet(
                        joinFirstNames(l10n, section.childNames),
                      ),
                      style: context.typography.cardTitle,
                    ),
                    Text(
                      l10n.clientHomeOpenNegotiations(section.openNegotiations),
                      style: context.typography.cardSubtitle,
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
                  label: l10n.clientHomeSeeProposals,
                  onPressed: onSeeProposalsTapped,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VanepSecondaryButton(
                  label: l10n.clientHomeSearchVans,
                  icon: Icons.search,
                  onPressed: onSearchVansTapped,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
