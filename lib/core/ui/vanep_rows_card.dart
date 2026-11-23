import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepSectionHeader extends StatelessWidget {
  const VanepSectionHeader({
    required this.title,
    this.titleDetail,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? titleDetail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final detail = titleDetail;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: title,
                style: VanepTypography.sectionTitle,
                children: [
                  if (detail != null)
                    TextSpan(
                      text: ' $detail',
                      style: VanepTypography.cardSubtitle,
                    ),
                ],
              ),
            ),
          ),
          if (label != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(label, style: VanepTypography.linkAction),
            ),
        ],
      ),
    );
  }
}

class VanepRowsCard extends StatelessWidget {
  const VanepRowsCard({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VanepColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        side: const BorderSide(color: VanepColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: VanepColors.divider,
              ),
            row,
          ],
        ],
      ),
    );
  }
}
