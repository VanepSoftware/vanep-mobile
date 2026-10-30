import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepSearchField extends StatefulWidget {
  const VanepSearchField({
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<VanepSearchField> createState() => VanepSearchFieldState();
}

class VanepSearchFieldState extends State<VanepSearchField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
      borderSide: const BorderSide(color: VanepColors.cardBorder),
    );

    return TextField(
      controller: controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: VanepTypography.fieldValue,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: VanepTypography.fieldValue.copyWith(
          color: VanepColors.textMuted,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: VanepColors.textSecondary,
        ),
        filled: true,
        fillColor: VanepColors.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: VanepColors.action),
        ),
      ),
    );
  }
}
