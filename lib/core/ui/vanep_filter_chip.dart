import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepFilterChip extends StatelessWidget {
  const VanepFilterChip({
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
      toggled: isSelected,
      child: Material(
        color: isSelected
            ? context.palette.actionSurface
            : context.palette.card,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected
                ? context.palette.actionBorder
                : context.palette.inputBorder,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? context.palette.action
                        : context.palette.textPrimary,
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
