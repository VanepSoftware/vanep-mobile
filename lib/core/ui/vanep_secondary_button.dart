import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepSecondaryButton extends StatelessWidget {
  const VanepSecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.leading,
    this.onBrand = false,
    super.key,
  }) : assert(icon == null || leading == null);

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  // For marks that are not an icon font glyph, such as a brand logo.
  final Widget? leading;

  final bool onBrand;

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
              : VanepColors.textPrimary,
          disabledForegroundColor: VanepColors.textMuted,
          side: onBrand
              ? BorderSide.none
              : const BorderSide(color: VanepColors.inputBorder),
          backgroundColor: onBrand
              ? VanepColors.onBrand.withValues(alpha: 0.14)
              : VanepColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: VanepColors.action,
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
                      style: VanepTypography.button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
