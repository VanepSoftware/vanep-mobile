import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

/// The single primary action button of the design system (constitution R10b).
///
/// Shows a spinner and blocks taps while [isLoading] is true.
class VanepPrimaryButton extends StatelessWidget {
  const VanepPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: VanepColors.brand,
          foregroundColor: VanepColors.backgroundDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: VanepColors.backgroundDeep,
                ),
              )
            : Text(label, style: VanepTypography.button),
      ),
    );
  }
}
