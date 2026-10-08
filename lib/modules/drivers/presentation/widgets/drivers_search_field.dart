import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_text_field.dart';

class DriversSearchField extends StatelessWidget {
  const DriversSearchField({
    required this.hint,
    required this.onTap,
    super.key,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      textInputAction: TextInputAction.search,
      style: VanepTypography.fieldValue.copyWith(
        color: VanepColors.textPrimary,
        fontSize: 15,
      ),
      decoration: vanepInputDecoration(
        hintText: hint,
        prefixIcon: Icons.search,
      ),
    );
  }
}
