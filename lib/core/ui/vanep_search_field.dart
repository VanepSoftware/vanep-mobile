import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

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
    final palette = context.palette;
    final typography = context.typography;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(VanepTheme.cardRadius),
      borderSide: BorderSide(color: palette.cardBorder),
    );

    return TextField(
      controller: controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: typography.fieldValue,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: typography.fieldValue.copyWith(color: palette.textMuted),
        prefixIcon: Icon(Icons.search_rounded, color: palette.textSecondary),
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: palette.action),
        ),
      ),
    );
  }
}
