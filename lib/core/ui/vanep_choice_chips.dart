import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepChoice<T> {
  const VanepChoice({required this.value, required this.label});

  final T value;

  final String label;
}

class VanepChoiceChips<T> extends StatelessWidget {
  const VanepChoiceChips({
    required this.choices,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<VanepChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, choice) in choices.indexed) ...[
            if (index > 0) const SizedBox(width: 8),
            VanepChoiceChip(
              label: choice.label,
              isSelected: choice.value == selected,
              onTap: () => onSelected(choice.value),
            ),
          ],
        ],
      ),
    );
  }
}

class VanepChoiceChip extends StatelessWidget {
  const VanepChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? VanepColors.textPrimary : VanepColors.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? VanepColors.textPrimary : VanepColors.cardBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: VanepTypography.ratingLabel.copyWith(
                    color: isSelected
                        ? VanepColors.onBrand
                        : VanepColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
