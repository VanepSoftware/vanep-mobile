import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

const proposalSectionSpacing = 20.0;

final proposalValueStyle = VanepTypography.cardTitle.copyWith(fontSize: 14);

final proposalLabelStyle = VanepTypography.cardSubtitle.copyWith(
  fontSize: 14,
);

class ProposalDetailRow extends StatelessWidget {
  const ProposalDetailRow({
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: proposalLabelStyle),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: proposalValueStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProposalChevronRow extends StatelessWidget {
  const ProposalChevronRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: VanepTypography.cardSubtitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: VanepTypography.cardTitle),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: VanepColors.textMuted),
          ],
        ),
      ),
    );
  }
}
