import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

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
          backgroundColor: VanepColors.action,
          foregroundColor: VanepColors.card,
          disabledBackgroundColor: VanepColors.action.withValues(
            alpha: isLoading ? 0.75 : 0.45,
          ),
          disabledForegroundColor: VanepColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: VanepColors.card,
                ),
              )
            : Text(label, style: VanepTypography.button),
      ),
    );
  }
}
