import 'package:flutter/material.dart';

import '../../../../core/design_system/vanep_colors.dart';
import '../../../../core/design_system/vanep_typography.dart';

class DriversSearchField extends StatelessWidget {
  const DriversSearchField({required this.hint, required this.onTap, super.key});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      textInputAction: TextInputAction.search,
      style: VanepTypography.cardSubtitle.copyWith(
        color: VanepColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: VanepColors.searchField,
        hintText: hint,
        hintStyle: VanepTypography.cardSubtitle.copyWith(fontSize: 15),
        prefixIcon: const Icon(
          Icons.search,
          color: VanepColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: VanepColors.brand, width: 1.5),
        ),
      ),
    );
  }
}
