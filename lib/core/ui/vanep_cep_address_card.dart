import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

class VanepCepAddressCard extends StatelessWidget {
  const VanepCepAddressCard({
    required this.neighborhood,
    required this.city,
    required this.uf,
    super.key,
  });

  final String neighborhood;
  final String city;
  final String uf;

  @override
  Widget build(BuildContext context) {
    final place = '$city – $uf';
    final text = neighborhood.isEmpty ? place : '$neighborhood, $place';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: VanepColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VanepColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: VanepColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: VanepTypography.fieldValue)),
          ],
        ),
      ),
    );
  }
}
