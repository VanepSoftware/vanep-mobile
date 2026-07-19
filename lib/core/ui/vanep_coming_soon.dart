import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

class VanepComingSoon extends StatelessWidget {
  const VanepComingSoon({required this.title, required this.message, super.key});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: VanepTypography.pageTitle),
            const SizedBox(height: 8),
            Text(
              message,
              style: VanepTypography.cardSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.hourglass_empty,
              color: VanepColors.textMuted,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
