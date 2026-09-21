import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/ui/vanep_page_chrome.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dependent.dart';
import '../formatters/dependent_labels.dart';

class DependentCard extends StatelessWidget {
  const DependentCard({
    required this.dependent,
    required this.onEdit,
    required this.canChooseDefault,
    required this.onChooseDefault,
    super.key,
  });

  final Dependent dependent;
  final VoidCallback onEdit;
  final bool canChooseDefault;
  final VoidCallback onChooseDefault;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final age = dependentAgeLabel(l10n, dependent.birthDate);

    return VanepOutlinedPanel(
      highlighted: dependent.isDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dependent.name, style: VanepTypography.cardTitle),
                    if (age != null)
                      Text(age, style: VanepTypography.cardSubtitle),
                    Text(
                      dependentAddressLabel(l10n, dependent.address),
                      style: VanepTypography.cardSubtitle,
                    ),
                  ],
                ),
              ),
              if (dependent.isDefault) const DependentDefaultBadge(),
              IconButton(
                tooltip: l10n.dependentFormEditTitle,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: VanepColors.textSecondary,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
          if (canChooseDefault && !dependent.isDefault)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onChooseDefault,
                child: Text(
                  l10n.dependentsSetDefault,
                  style: VanepTypography.cardSubtitle.copyWith(
                    color: VanepColors.action,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget buildDependentCardSkeleton(BuildContext context) {
  return const DependentCardSkeleton();
}

/// Placeholder with the shape of a [DependentCard]: name, age, address and
/// the edit action, so the list does not jump once the dependents arrive.
class DependentCardSkeleton extends StatelessWidget {
  const DependentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const VanepOutlinedPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(words: 2, fontSize: 16),
                SizedBox(height: 4),
                Bone.text(width: 72, fontSize: 13),
                SizedBox(height: 4),
                Bone.text(words: 4, fontSize: 13),
              ],
            ),
          ),
          SizedBox(width: 12),
          Bone.icon(size: 24),
        ],
      ),
    );
  }
}

class DependentDefaultBadge extends StatelessWidget {
  const DependentDefaultBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: VanepColors.action.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.dependentsDefaultBadge,
        style: VanepTypography.cardSubtitle.copyWith(
          color: VanepColors.action,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
