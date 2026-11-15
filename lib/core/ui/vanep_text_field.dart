import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepTextField extends StatefulWidget {
  const VanepTextField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.isRequired = false,
    this.errorText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.isLoading = false,
    this.loadingLabel,
    this.labelTrailing,
    this.suffix,
    this.onTap,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool isRequired;
  final String? errorText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final bool isLoading;
  final String? loadingLabel;
  final Widget? labelTrailing;
  final Widget? suffix;
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
        VanepFieldLabel(
          label: widget.label,
          isRequired: widget.isRequired,
          trailing: widget.labelTrailing,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          obscureText: _textHidden,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          cursorColor: context.palette.action,
          style: context.typography.fieldValue.copyWith(
            color: widget.enabled
                ? context.palette.textPrimary
                : context.palette.textMuted,
          ),
          decoration: vanepInputDecoration(
            context,
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? TextVisibilityToggle(
                    textHidden: _textHidden,
                    onPressed: toggleTextVisibility,
                  )
                : (widget.isLoading
                      ? VanepFieldSpinner(label: widget.loadingLabel)
                      : widget.suffix),
          ),
        ),
      ],
    );
  }
}

InputDecoration vanepInputDecoration(
  BuildContext context, {
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
    fillColor: context.palette.card,
    isDense: true,
    hintText: hintText,
    hintStyle: context.typography.fieldValue.copyWith(
      color: context.palette.placeholder,
    ),
    counterText: '',
    errorText: errorText,
    errorStyle: context.typography.cardSubtitle.copyWith(
      color: context.palette.danger,
      fontSize: 12,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: context.palette.textSecondary),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: outline(context.palette.inputBorder),
    enabledBorder: outline(context.palette.inputBorder),
    disabledBorder: outline(context.palette.divider),
    focusedBorder: outline(context.palette.action, width: 1.5),
    errorBorder: outline(context.palette.danger),
    focusedErrorBorder: outline(context.palette.danger, width: 1.5),
  );
}

class VanepFieldSpinner extends StatelessWidget {
  const VanepFieldSpinner({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.palette.action,
          ),
        ),
      ),
    );
  }
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
      color: context.palette.textSecondary,
      icon: Icon(
        textHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
      ),
    );
  }
}

class VanepFieldLabel extends StatelessWidget {
  const VanepFieldLabel({
    required this.label,
    this.isRequired = false,
    this.trailing,
    super.key,
  });

  final String label;
  final bool isRequired;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Text(label, style: context.typography.fieldLabel);
    final title = isRequired
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: text),
              const SizedBox(width: 4),
              Text(
                '*',
                style: context.typography.fieldLabel.copyWith(
                  color: context.palette.danger,
                ),
              ),
            ],
          )
        : text;
    final trailing = this.trailing;
    if (trailing == null) return title;
    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}
