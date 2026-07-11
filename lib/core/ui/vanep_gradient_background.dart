import 'package:flutter/material.dart';

import '../design_system/vanep_colors.dart';

/// Shared navy gradient backdrop with the two teal glows (constitution R10b).
///
/// Extracted from the original splash screen so every full-screen page reuses
/// the same brand chrome instead of re-declaring the gradients.
class VanepGradientBackground extends StatelessWidget {
  const VanepGradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // Base navy gradient (linear-gradient 155deg from the frontend).
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.6, 1),
          colors: [
            VanepColors.backgroundDeep,
            VanepColors.backgroundMid,
            VanepColors.backgroundSoft,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Teal glow, upper-right (radial-gradient at 72% 38%).
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.44, -0.24),
                  radius: 1.1,
                  colors: [
                    VanepColors.glowPrimary,
                    VanepColors.glowPrimaryFade,
                  ],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
          // Softer glow, lower-left (radial-gradient at 8% 88%).
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.84, 0.76),
                  radius: 1.0,
                  colors: [
                    VanepColors.glowSecondary,
                    VanepColors.glowSecondaryFade,
                  ],
                  stops: [0.0, 0.55],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
