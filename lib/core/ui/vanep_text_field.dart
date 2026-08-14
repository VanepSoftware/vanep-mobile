import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

class VanepTextField extends StatelessWidget {
  const VanepTextField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: VanepTypography.cardSubtitle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          onChanged: onChanged,
          style: VanepTypography.cardTitle.copyWith(
            color: enabled ? VanepColors.textPrimary : VanepColors.textMuted,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: VanepColors.searchField,
            hintText: null,
            counterText: '',
            errorText: errorText,
            errorStyle: VanepTypography.cardSubtitle.copyWith(
              color: VanepColors.danger,
              fontSize: 12,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: VanepColors.brand, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: VanepColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: VanepColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
