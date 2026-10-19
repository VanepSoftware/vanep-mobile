import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepSection extends StatelessWidget {
  const VanepSection({
    required this.child,
    this.title,
    this.note,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? note;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    if (title == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: VanepSectionHeader(
            title: title,
            note: note,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
        child,
      ],
    );
  }
}

class VanepSectionHeader extends StatelessWidget {
  const VanepSectionHeader({
    required this.title,
    this.note,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? note;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    final actionLabel = this.actionLabel;
    final onAction = this.onAction;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: VanepTypography.sectionTitle.copyWith(
              color: VanepColors.textPrimary,
            ),
          ),
        ),
        if (note != null)
          Text(
            note,
            style: VanepTypography.cardSubtitle.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(44, 44),
            ),
            child: Text(
              actionLabel,
              style: VanepTypography.linkAction.copyWith(fontSize: 14),
            ),
          ),
      ],
    );
  }
}
