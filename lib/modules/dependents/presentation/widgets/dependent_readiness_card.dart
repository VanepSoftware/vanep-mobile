import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_labels.dart';
import 'package:vanep_mobile/modules/dependents/presentation/formatters/dependent_readiness_items.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
    final labelStyle = context.typography.ratingLabel.copyWith(
      color: context.palette.warningText,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.warningSurfaceSoft,
        borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
        border: Border.all(color: context.palette.warningBorder),
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
            style: context.typography.cardTitle.copyWith(
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
            color: isDone
                ? context.palette.success
                : context.palette.warningText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dependentReadinessItemLabel(l10n, item.step),
              style: context.typography.body.copyWith(
                fontSize: 14,
                fontWeight: isDone ? FontWeight.w400 : FontWeight.w700,
                color: isDone
                    ? context.palette.textSecondary
                    : context.palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
