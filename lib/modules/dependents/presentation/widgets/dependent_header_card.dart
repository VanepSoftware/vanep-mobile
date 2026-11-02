import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';

class DependentHeaderCard extends StatelessWidget {
  const DependentHeaderCard({required this.dependent, super.key});

  final Dependent dependent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details = [
      ?dependentAgeLabel(l10n, dependent.birthDate),
      if (dependent.isDefault) l10n.dependentDetailDefaultNote,
    ];

    return VanepCard(
      child: Row(
        children: [
          VanepInitialAvatar(
            name: dependent.name,
            seed: dependent.token,
            size: 56,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dependent.name,
                  style: VanepTypography.cardTitle.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details.join(' · '),
                    style: VanepTypography.cardSubtitle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
