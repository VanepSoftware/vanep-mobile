import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_readiness_items.dart';

class DependentReadinessCard extends StatelessWidget {
  const DependentReadinessCard({
    required this.gaps,
    required this.onComplete,
    super.key,
  });

  final Set<ContractReadinessField> gaps;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = dependentReadinessItems(gaps);
    final labelStyle = VanepTypography.ratingLabel.copyWith(
      color: VanepColors.warningText,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VanepColors.warningSurfaceSoft,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        border: Border.all(color: VanepColors.warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dependentsIncomplete.toUpperCase(),
                  style: labelStyle.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              Text(
                l10n.dependentReadinessCount(
                  countDoneReadinessItems(items),
                  items.length,
                ),
                style: labelStyle.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.dependentReadinessTitle,
            style: VanepTypography.cardTitle.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          for (final item in items) DependentReadinessItemRow(item: item),
          const SizedBox(height: 12),
          VanepPrimaryButton(
            label: l10n.dependentReadinessAction,
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}

class DependentReadinessItemRow extends StatelessWidget {
  const DependentReadinessItemRow({required this.item, super.key});

  final DependentReadinessItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDone = item.isDone;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 22,
            color: isDone ? VanepColors.success : VanepColors.warningText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dependentReadinessItemLabel(l10n, item.step),
              style: VanepTypography.body.copyWith(
                fontSize: 14,
                fontWeight: isDone ? FontWeight.w400 : FontWeight.w700,
                color: isDone
                    ? VanepColors.textSecondary
                    : VanepColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
