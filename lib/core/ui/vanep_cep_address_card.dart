import 'package:flutter/material.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: context.palette.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: context.typography.fieldValue)),
          ],
        ),
      ),
    );
  }
}
