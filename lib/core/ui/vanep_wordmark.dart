import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';
import '../design_system/vanep_typography.dart';

class VanepWordmark extends StatelessWidget {
  const VanepWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      const TextSpan(
        children: [
          TextSpan(
            text: 'vanep',
            style: TextStyle(color: VanepColors.foreground),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(color: VanepColors.brand),
          ),
        ],
        style: VanepTypography.wordmark,
      ),
    );
  }
}
