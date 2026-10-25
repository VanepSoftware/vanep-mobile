import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';

class VanepPrimaryButton extends StatelessWidget {
  const VanepPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.onBrand = false,
    this.trailingIcon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool onBrand;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final background = onBrand ? VanepColors.card : VanepColors.action;
    final foreground = onBrand ? VanepColors.brandNavy : VanepColors.card;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(
            alpha: isLoading ? 0.75 : 0.45,
          ),
          disabledForegroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: foreground,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: VanepTypography.button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
