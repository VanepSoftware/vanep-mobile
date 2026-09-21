import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

class VanepWordmark extends StatelessWidget {
  const VanepWordmark({
    this.color = VanepColors.textPrimary,
    this.fontSize,
    super.key,
  });

  final Color color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'vanep',
            style: TextStyle(color: color),
          ),
          const TextSpan(
            text: '.',
            style: TextStyle(color: VanepColors.action),
          ),
        ],
        style: VanepTypography.wordmark.copyWith(fontSize: fontSize),
      ),
    );
  }
}
