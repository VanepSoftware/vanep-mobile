import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

class VanepTextField extends StatefulWidget {
  const VanepTextField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? errorText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;

  @override
  State<VanepTextField> createState() => _VanepTextFieldState();
}

class _VanepTextFieldState extends State<VanepTextField> {
  late bool _textHidden = widget.obscureText;

  void toggleTextVisibility() => setState(() => _textHidden = !_textHidden);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: VanepTypography.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          obscureText: _textHidden,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          cursorColor: VanepColors.action,
          style: VanepTypography.fieldValue.copyWith(
            color: widget.enabled
                ? VanepColors.textPrimary
                : VanepColors.textMuted,
          ),
          decoration: vanepInputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? TextVisibilityToggle(
                    textHidden: _textHidden,
                    onPressed: toggleTextVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

InputDecoration vanepInputDecoration({
  String? hintText,
  String? errorText,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder outline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    filled: true,
    fillColor: VanepColors.card,
    isDense: true,
    hintText: hintText,
    hintStyle: VanepTypography.fieldValue.copyWith(
      color: VanepColors.placeholder,
    ),
    counterText: '',
    errorText: errorText,
    errorStyle: VanepTypography.cardSubtitle.copyWith(
      color: VanepColors.danger,
      fontSize: 12,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: VanepColors.textSecondary),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: outline(VanepColors.inputBorder),
    enabledBorder: outline(VanepColors.inputBorder),
    disabledBorder: outline(VanepColors.divider),
    focusedBorder: outline(VanepColors.action, width: 1.5),
    errorBorder: outline(VanepColors.danger),
    focusedErrorBorder: outline(VanepColors.danger, width: 1.5),
  );
}

class TextVisibilityToggle extends StatelessWidget {
  const TextVisibilityToggle({
    required this.textHidden,
    required this.onPressed,
    super.key,
  });

  final bool textHidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: onPressed,
      tooltip: textHidden ? l10n?.showPassword : l10n?.hidePassword,
      color: VanepColors.textSecondary,
      icon: Icon(
        textHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
      ),
    );
  }
}
