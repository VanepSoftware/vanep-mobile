import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';
import '../domain/gender.dart';

class VanepGenderChips extends StatelessWidget {
  const VanepGenderChips({
    required this.value,
    required this.onChanged,
    required this.labelOf,
    super.key,
  });

  final Gender? value;
  final ValueChanged<Gender> onChanged;
  final String Function(Gender gender) labelOf;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final gender in Gender.values)
          VanepGenderChip(
            label: labelOf(gender),
            selected: value == gender,
            onTap: () => onChanged(gender),
          ),
      ],
    );
  }
}

class VanepGenderChip extends StatelessWidget {
  const VanepGenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VanepColors.actionSurface : VanepColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? VanepColors.action : VanepColors.inputBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: VanepTypography.cardSubtitle.copyWith(
              color: selected ? VanepColors.action : VanepColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
