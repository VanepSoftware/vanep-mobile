import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_text_field.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
      style: context.typography.fieldValue.copyWith(
        color: context.palette.textPrimary,
        fontSize: 15,
      ),
      decoration: vanepInputDecoration(
        context,
        hintText: hint,
        prefixIcon: Icons.search,
      ),
    );
  }
}
