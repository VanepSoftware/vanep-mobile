import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';

class VanepChoice<T> {
  const VanepChoice({required this.value, required this.label});

  final T value;

  final String label;
}

class VanepChoiceChips<T> extends StatelessWidget {
  const VanepChoiceChips({
    required this.label,
    required this.choices,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final List<VanepChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VanepFieldLabel(label: label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in choices)
              VanepChoicePill(
                label: choice.label,
                isSelected: choice.value == selected,
                onTap: () => onSelected(choice.value),
              ),
          ],
        ),
      ],
    );
  }
}

class VanepChoicePill extends StatelessWidget {
  const VanepChoicePill({
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
      child: Material(
        color: isSelected ? VanepColors.actionSurface : VanepColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VanepTheme.controlRadius),
          side: BorderSide(
            color: isSelected ? VanepColors.action : VanepColors.inputBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? VanepColors.action
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
