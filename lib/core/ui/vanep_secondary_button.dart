import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

class VanepSecondaryButton extends StatelessWidget {
  const VanepSecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.leading,
    this.onBrand = false,
    this.isDestructive = false,
    super.key,
  }) : assert(icon == null || leading == null);

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  // For marks that are not an icon font glyph, such as a brand logo.
  final Widget? leading;

  final bool onBrand;

  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: onBrand
              ? VanepColors.onBrand
              : (isDestructive
                    ? context.palette.dangerText
                    : context.palette.textPrimary),
          disabledForegroundColor: context.palette.textMuted,
          side: onBrand
              ? BorderSide.none
              : BorderSide(
                  color: isDestructive
                      ? context.palette.dangerBorder
                      : context.palette.inputBorder,
                ),
          backgroundColor: onBrand
              ? VanepColors.onBrand.withValues(alpha: 0.14)
              : (isDestructive
                    ? context.palette.dangerSurface
                    : context.palette.card),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: context.palette.action,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null || leading != null) ...[
                    leading ?? Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: context.typography.button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
